extends Node3D
## Main scene manager.
## Spawns the player at the prototype SpawnPoint and registers cheat commands.

const SPAWN_POINT_GROUP := "spawn_point"

const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")
const CHEAT_INDICATOR_SCENE: PackedScene = preload("res://ui/hud/cheat_indicator.tscn")
const INTERACTION_PROMPT_SCENE: PackedScene = preload("res://ui/hud/interaction_prompt.tscn")
const INVENTORY_UI_SCENE: PackedScene = preload("res://ui/inventory/inventory_ui.tscn")
const HOTBAR_UI_SCENE: PackedScene = preload("res://ui/hud/hotbar_ui.tscn")
const SCREEN_EFFECTS_SCENE: PackedScene = preload("res://ui/hud/screen_effects.tscn")
const STATS_HUD_SCENE: PackedScene = preload("res://ui/hud/stats_hud.tscn")
const DEATH_SCREEN_SCENE: PackedScene = preload("res://ui/hud/death_screen.tscn")

var _player: PlayerController
var _cheat_indicator: Node
var _interaction_prompt: InteractionPrompt
var _inventory_ui: InventoryUI
var _hotbar_ui: HotbarUI
var _screen_effects: ScreenEffects
var _stats_hud: StatsHUD
var _death_screen: DeathScreen
var _survival: PlayerSurvival

@onready var _prototype: Node3D = $Prototype


func _ready() -> void:
	_setup_ui()
	_spawn_player()
	_register_commands()


func _setup_ui() -> void:
	_cheat_indicator = CHEAT_INDICATOR_SCENE.instantiate()
	add_child(_cheat_indicator)

	_interaction_prompt = INTERACTION_PROMPT_SCENE.instantiate()
	add_child(_interaction_prompt)

	_inventory_ui = INVENTORY_UI_SCENE.instantiate()
	add_child(_inventory_ui)

	_hotbar_ui = HOTBAR_UI_SCENE.instantiate()
	add_child(_hotbar_ui)

	_screen_effects = SCREEN_EFFECTS_SCENE.instantiate()
	add_child(_screen_effects)

	_stats_hud = STATS_HUD_SCENE.instantiate()
	add_child(_stats_hud)

	_death_screen = DEATH_SCREEN_SCENE.instantiate()
	add_child(_death_screen)


func _input(event: InputEvent) -> void:
	# Toggle inventory with Tab (only when console is closed)
	if event.is_action_pressed("toggle_inventory"):
		if is_instance_valid(Debug.console) and Debug.console.is_open():
			return
		_inventory_ui.toggle()
		get_viewport().set_input_as_handled()


func _spawn_player() -> void:
	var spawn_point: Marker3D = _find_spawn_point()
	if not is_instance_valid(spawn_point):
		push_error("No spawn point found in group '%s'. Add the group to a Marker3D." % SPAWN_POINT_GROUP)
		return

	_player = PLAYER_SCENE.instantiate()
	add_child(_player)
	_player.global_position = spawn_point.global_position
	_player.rotation.y = spawn_point.rotation.y
	_player.set_spawn(spawn_point.global_position, spawn_point.rotation.y)
	Debug.ok("Player spawned at SpawnPoint %s" % spawn_point.global_position)

	_player.cheat_mode_changed.connect(_on_cheat_mode_changed)
	_player.damaged.connect(_on_player_damaged)

	var interaction: PlayerInteraction = _player.get_node_or_null("Interaction")
	if is_instance_valid(interaction):
		_interaction_prompt.setup(interaction)

	var inventory_node: PlayerInventory = _player.get_node_or_null("Inventory")
	if is_instance_valid(inventory_node):
		_inventory_ui.setup(inventory_node.inventory)
		_hotbar_ui.setup(inventory_node.hotbar)
		_inventory_ui.setup_hotbar(_hotbar_ui, inventory_node.hotbar)

	# Connect item usage signals so ItemDefinition.use() is called on consumption.
	_inventory_ui.item_used.connect(_on_item_used)
	_hotbar_ui.item_used.connect(_on_item_used)

	_survival = _player.get_node_or_null("Survival")
	if not is_instance_valid(_survival):
		push_error("Player scene is missing required child node 'Survival'.")
		return

	_screen_effects.setup(_survival)
	_stats_hud.setup(_survival)
	_survival.died.connect(_on_player_died)
	if not _death_screen.respawn_pressed.is_connected(_on_respawn_pressed):
		_death_screen.respawn_pressed.connect(_on_respawn_pressed)


func _find_spawn_point() -> Marker3D:
	var nodes := get_tree().get_nodes_in_group(SPAWN_POINT_GROUP)
	if nodes.is_empty():
		return null
	var marker := nodes[0] as Marker3D
	if not is_instance_valid(marker):
		return null
	return marker


func _on_cheat_mode_changed(mode: String, active: bool) -> void:
	_cheat_indicator.set_cheat(mode, active)


## Flash colours per damage type (peak alpha baked in).
const DAMAGE_FLASH_COLORS: Dictionary = {
	"physical":    Color(1.0,  0.05, 0.05, 0.40),
	"fire":        Color(1.0,  0.45, 0.0,  0.40),
	"electric":    Color(0.9,  0.95, 0.2,  0.40),
	"toxic":       Color(0.1,  0.85, 0.1,  0.40),
	"suffocation": Color(0.4,  0.55, 0.9,  0.40),
}

func _on_player_damaged(amount: float, type: String) -> void:
	var color: Color = DAMAGE_FLASH_COLORS.get(type, Color(1, 0, 0, 0.35))
	_screen_effects.flash(color, 0.35)
	Debug.warn("Player took %.1f %s damage" % [amount, type])


func _on_player_died(cause: String) -> void:
	Debug.warn("Player died: %s" % cause)

	# Drop all inventory at death location in the active gameplay scene.
	_player.drop_inventory_at(_player.global_position, _prototype)

	_death_screen.show_death(cause)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_respawn_pressed() -> void:
	_death_screen.hide_death()
	_survival.reset_for_respawn()
	_player.respawn()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _register_commands() -> void:
	var console: DebugConsole = Debug.console

	console.register_command("noclip",   _cmd_noclip,   "Toggle noclip (fly through walls)")
	console.register_command("fly",      _cmd_fly,      "Toggle fly mode (no gravity, keeps collision)")
	console.register_command("speed",    _cmd_speed,    "Get/set speed multiplier. Usage: speed [value]")
	console.register_command("respawn",  _cmd_respawn,  "Teleport to spawn point")
	console.register_command("tp",       _cmd_tp,       "Teleport. Usage: tp <x> <y> <z>")
	console.register_command("spawn",    _cmd_spawn,    "Spawn item. Usage: spawn <item_id> [quantity]")
	console.register_command("items",    _cmd_items,    "List all available item IDs")
	console.register_command("inv",      _cmd_inv,      "Show inventory contents")
	console.register_command("give",     _cmd_give,     "Add item to inventory. Usage: give <item_id> [quantity]")
	# Phase 4.1 — survival debug commands
	console.register_command("god",      _cmd_god,      "Toggle god mode (no health loss)")
	console.register_command("heal",     _cmd_heal,     "Restore stat. Usage: heal [stat] [amount]  (default: health 100)")
	console.register_command("damage",   _cmd_damage,   "Drain stat instantly. Usage: damage [stat] [amount]  (default: health 10)")
	console.register_command("drain",    _cmd_drain,    "Drain all survival stats by amount. Usage: drain [amount]  (default: 10)")
	# Phase 4.2 — drain toggle
	console.register_command("nodrain",  _cmd_nodrain,  "Toggle passive stat drain on/off")
	# Phase 4.3 — screen effects toggle
	console.register_command("effects",  _cmd_effects,  "Toggle screen visual effects (vignette, desaturation)")
	# Phase 4.4 — stats HUD
	console.register_command("hud",      _cmd_hud,      "Toggle numeric values on stats HUD")
	# Phase 4.5 — consumable test
	console.register_command("useitem",  _cmd_useitem,  "Give and instantly use a consumable. Usage: useitem <item_id>")


func _get_player() -> PlayerController:
	if is_instance_valid(_player):
		return _player
	Debug.error("No player instance found")
	return null


func _cmd_noclip(_args: Array[String]) -> void:
	var p := _get_player()
	if not is_instance_valid(p):
		return
	# MoveMode enum: 0=NORMAL, 1=FLY, 2=NOCLIP
	var active: bool = p.move_mode != 2
	p.set_noclip(active)
	_cheat_indicator.set_cheat("noclip", active, "NOCLIP")
	Debug.ok("Noclip: %s" % ("ON" if active else "OFF"))


func _cmd_fly(_args: Array[String]) -> void:
	var p := _get_player()
	if not is_instance_valid(p):
		return
	var active: bool = p.move_mode != 1
	p.set_fly(active)
	_cheat_indicator.set_cheat("fly", active, "FLY")
	Debug.ok("Fly: %s" % ("ON" if active else "OFF"))


func _cmd_speed(args: Array[String]) -> void:
	var p := _get_player()
	if not is_instance_valid(p):
		return
	if args.is_empty():
		Debug.info("Speed multiplier: %.2f" % p.speed_multiplier)
		return
	var val := args[0].to_float()
	if val < 0.1 or val > 100.0:
		Debug.warn("Speed must be between 0.1 and 100")
		return
	p.speed_multiplier = val
	_cheat_indicator.set_cheat("speed", not is_equal_approx(val, 1.0), "SPEED x%.1f" % val)
	Debug.ok("Speed multiplier: %.2f" % val)


func _cmd_respawn(_args: Array[String]) -> void:
	var p := _get_player()
	if not is_instance_valid(p):
		return
	_survival.reset_for_respawn()
	p.respawn()
	_death_screen.hide_death()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _cmd_tp(args: Array[String]) -> void:
	var p := _get_player()
	if not is_instance_valid(p):
		return
	if args.size() < 3:
		Debug.warn("Usage: tp <x> <y> <z>")
		return
	p.global_position = Vector3(args[0].to_float(), args[1].to_float(), args[2].to_float())
	p.velocity = Vector3.ZERO
	Debug.ok("Teleported to (%.1f, %.1f, %.1f)" % [args[0].to_float(), args[1].to_float(), args[2].to_float()])


func _cmd_spawn(args: Array[String]) -> void:
	if args.is_empty():
		Debug.warn("Usage: spawn <item_id> [quantity]")
		return
	
	var item_id: String = args[0]
	var qty: int = 1
	if args.size() >= 2:
		qty = maxi(args[1].to_int(), 1)
	
	var p := _get_player()
	if not is_instance_valid(p):
		return

	# Spawn in front of player
	var spawn_pos: Vector3 = p.global_position + (-p.global_transform.basis.z * 2.0) + Vector3.UP

	if _prototype.spawn_item_at(item_id, spawn_pos, qty):
		Debug.ok("Spawned %dx %s" % [qty, item_id])
	else:
		Debug.error("Unknown item: %s (use 'items' to list)" % item_id)


func _cmd_items(_args: Array[String]) -> void:
	var ids := ItemDatabase.get_item_ids()
	Debug.info("Available items: %s" % ", ".join(ids))


func _cmd_inv(_args: Array[String]) -> void:
	var p := _get_player()
	if not is_instance_valid(p):
		return
	
	var inventory_node: PlayerInventory = p.get_node_or_null("Inventory")
	if not is_instance_valid(inventory_node):
		Debug.error("Player has no inventory")
		return

	inventory_node.print_inventory()


func _cmd_give(args: Array[String]) -> void:
	if args.is_empty():
		Debug.warn("Usage: give <item_id> [quantity]")
		return
	
	var item_id: String = args[0]
	var qty: int = 1
	if args.size() >= 2:
		qty = maxi(args[1].to_int(), 1)
	
	var p := _get_player()
	if not is_instance_valid(p):
		return
	
	var item_def := ItemDatabase.get_item(item_id)
	if not item_def:
		Debug.error("Unknown item: %s (use 'items' to list)" % item_id)
		return
	
	var inventory_node: PlayerInventory = p.get_node_or_null("Inventory")
	if not is_instance_valid(inventory_node):
		Debug.error("Player has no inventory")
		return
	
	var overflow: int = inventory_node.add_item(item_def, qty)
	
	if overflow == 0:
		Debug.ok("Added %dx %s to inventory" % [qty, item_def.display_name])
	else:
		var added := qty - overflow
		Debug.warn("Added %dx %s (overflow: %d)" % [added, item_def.display_name, overflow])


func _on_item_used(item: ItemDefinition, _slot_index: int) -> void:
	item.use(_player)
	# Visual feedback — show floating "+N stat" labels on the HUD.
	if item.restore_health > 0:
		_stats_hud.show_restore_feedback("health", item.restore_health)
	if item.restore_oxygen > 0:
		_stats_hud.show_restore_feedback("oxygen", item.restore_oxygen)
	if item.restore_hunger > 0:
		_stats_hud.show_restore_feedback("hunger", item.restore_hunger)
	if item.restore_thirst > 0:
		_stats_hud.show_restore_feedback("thirst", item.restore_thirst)


# ── Phase 4.1 survival debug commands ────────────────────────────────────────

func _get_survival() -> PlayerSurvival:
	if not is_instance_valid(_survival):
		Debug.error("Player has no Survival component")
		return null
	return _survival


func _cmd_god(_args: Array[String]) -> void:
	var p := _get_player()
	if not is_instance_valid(p):
		return
	p.god_mode = not p.god_mode
	_cheat_indicator.set_cheat("god", p.god_mode, "GOD")
	Debug.ok("God mode: %s" % ("ON" if p.god_mode else "OFF"))


func _cmd_heal(args: Array[String]) -> void:
	var survival := _get_survival()
	if not is_instance_valid(survival):
		return
	var stat_name := "health" if args.is_empty() else args[0]
	var amount := 100.0 if args.size() < 2 else args[1].to_float()
	if stat_name == "all":
		for s in ["health", "oxygen", "hunger", "thirst", "sanity", "stamina"]:
			survival.restore(s, amount)
		Debug.ok("Restored all stats by %.1f" % amount)
	else:
		survival.restore(stat_name, amount)
		Debug.ok("Restored %s by %.1f" % [stat_name, amount])


func _cmd_damage(args: Array[String]) -> void:
	var survival := _get_survival()
	if not is_instance_valid(survival):
		return
	var stat_name := "health" if args.is_empty() else args[0]
	var amount := 10.0 if args.size() < 2 else args[1].to_float()
	if stat_name == "all":
		for s in ["health", "oxygen", "hunger", "thirst", "sanity", "stamina"]:
			survival.drain(s, amount)
		Debug.ok("Drained all stats by %.1f" % amount)
	elif stat_name == "health":
		# Route through take_damage so screen flash + invincibility frames fire.
		var p := _get_player()
		if not is_instance_valid(p):
			return
		p.take_damage(amount, "physical")
		Debug.ok("Dealt %.1f physical damage" % amount)
	else:
		survival.drain(stat_name, amount)
		Debug.ok("Drained %s by %.1f" % [stat_name, amount])


func _cmd_drain(args: Array[String]) -> void:
	var survival := _get_survival()
	if not is_instance_valid(survival):
		return
	var amount := 10.0 if args.is_empty() else args[0].to_float()
	for s in ["health", "oxygen", "hunger", "thirst", "sanity", "stamina"]:
		survival.drain(s, amount)
	Debug.ok("Drained all stats by %.1f" % amount)


func _cmd_nodrain(_args: Array[String]) -> void:
	var survival := _get_survival()
	if not is_instance_valid(survival):
		return
	survival.draining_enabled = not survival.draining_enabled
	var state := "ON" if survival.draining_enabled else "OFF"
	_cheat_indicator.set_cheat("nodrain", not survival.draining_enabled, "NO DRAIN")
	Debug.ok("Passive drain: %s" % state)


# ── Phase 4.3 screen effects command ─────────────────────────────────────────

func _cmd_effects(_args: Array[String]) -> void:
	_screen_effects.effects_enabled = not _screen_effects.effects_enabled
	var state := "ON" if _screen_effects.effects_enabled else "OFF"
	Debug.ok("Screen effects: %s" % state)


# ── Phase 4.4 stats HUD command ───────────────────────────────────────────────

func _cmd_hud(_args: Array[String]) -> void:
	_stats_hud.toggle_numbers()
	Debug.ok("Stats HUD numbers toggled")


# ── Phase 4.5 consumable test command ────────────────────────────────────────

func _cmd_useitem(args: Array[String]) -> void:
	if args.is_empty():
		Debug.warn("Usage: useitem <item_id>")
		return
	var item_def := ItemDatabase.get_item(args[0])
	if not item_def:
		Debug.error("Unknown item: %s (use 'items' to list)" % args[0])
		return
	var p := _get_player()
	if not is_instance_valid(p):
		return
	item_def.use(p)
	# Visual feedback on HUD.
	if item_def.restore_health > 0:
		_stats_hud.show_restore_feedback("health", item_def.restore_health)
	if item_def.restore_oxygen > 0:
		_stats_hud.show_restore_feedback("oxygen", item_def.restore_oxygen)
	if item_def.restore_hunger > 0:
		_stats_hud.show_restore_feedback("hunger", item_def.restore_hunger)
	if item_def.restore_thirst > 0:
		_stats_hud.show_restore_feedback("thirst", item_def.restore_thirst)
	Debug.ok("Used %s" % item_def.display_name)
