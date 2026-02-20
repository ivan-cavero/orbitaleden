extends Node3D
## Main scene manager.
## Spawns the player at the prototype SpawnPoint and registers cheat commands.

const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")
const CHEAT_INDICATOR_SCENE: PackedScene = preload("res://ui/hud/cheat_indicator.tscn")
const INTERACTION_PROMPT_SCENE: PackedScene = preload("res://ui/hud/interaction_prompt.tscn")
const INVENTORY_UI_SCENE: PackedScene = preload("res://ui/inventory/inventory_ui.tscn")
const HOTBAR_UI_SCENE: PackedScene = preload("res://ui/hud/hotbar_ui.tscn")

# Using Node type to avoid class_name load-order issues; cast at usage sites.
var _player: Node
var _cheat_indicator: Node
var _interaction_prompt: Node
var _inventory_ui: InventoryUI
var _hotbar_ui: Node


func _ready() -> void:
	_cheat_indicator = CHEAT_INDICATOR_SCENE.instantiate()
	add_child(_cheat_indicator)
	
	_interaction_prompt = INTERACTION_PROMPT_SCENE.instantiate()
	add_child(_interaction_prompt)

	_inventory_ui = INVENTORY_UI_SCENE.instantiate()
	add_child(_inventory_ui)

	_hotbar_ui = HOTBAR_UI_SCENE.instantiate()
	add_child(_hotbar_ui)

	_spawn_player()
	_register_commands()


func _input(event: InputEvent) -> void:
	# Toggle inventory with Tab (only when console is closed)
	if event.is_action_pressed("toggle_inventory"):
		if is_instance_valid(Debug.console) and Debug.console.is_open():
			return
		_inventory_ui.toggle()
		get_viewport().set_input_as_handled()


func _spawn_player() -> void:
	var spawn_point: Marker3D = _find_spawn_point()

	_player = PLAYER_SCENE.instantiate()
	add_child(_player)

	if is_instance_valid(spawn_point):
		_player.global_position = spawn_point.global_position
		_player.rotation.y = spawn_point.rotation.y
		_player.set_spawn(spawn_point.global_position, spawn_point.rotation.y)
		Debug.ok("Player spawned at SpawnPoint %s" % spawn_point.global_position)
	else:
		_player.global_position = Vector3(0.0, 1.0, 0.0)
		Debug.warn("No SpawnPoint found — player placed at origin")

	_player.cheat_mode_changed.connect(_on_cheat_mode_changed)
	
	# Setup interaction prompt
	var interaction: Node = _player.get_node_or_null("Interaction")
	if interaction:
		_interaction_prompt.setup(interaction)

	# Setup inventory UI
	var inventory_node: Node = _player.get_node_or_null("Inventory")
	if inventory_node and inventory_node.inventory:
		_inventory_ui.setup(inventory_node.inventory)

	# Setup hotbar
	if inventory_node and inventory_node.hotbar:
		_hotbar_ui.setup(inventory_node.hotbar)
		_inventory_ui.setup_hotbar(_hotbar_ui, inventory_node.hotbar)


func _find_spawn_point() -> Marker3D:
	# Look for any node in the spawn_point group
	var nodes := get_tree().get_nodes_in_group("spawn_point")
	if not nodes.is_empty():
		return nodes[0] as Marker3D
	# Fallback: direct path in prototype
	var direct: Node = get_node_or_null("Prototype/SpawnPoint")
	if is_instance_valid(direct) and direct is Marker3D:
		return direct as Marker3D
	return null


func _on_cheat_mode_changed(mode: String, active: bool) -> void:
	_cheat_indicator.set_cheat(mode, active)


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


func _get_player() -> Node:
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
	p.respawn()


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
	
	# Get prototype scene to spawn items
	var prototype: Node = get_node_or_null("Prototype")
	if not prototype or not prototype.has_method("spawn_item_at"):
		Debug.error("No prototype scene with spawn support")
		return
	
	# Spawn in front of player
	var spawn_pos: Vector3 = p.global_position + (-p.global_transform.basis.z * 2.0) + Vector3.UP
	
	if prototype.spawn_item_at(item_id, spawn_pos, qty):
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
	
	var inventory_node: Node = p.get_node_or_null("Inventory")
	if not inventory_node or not inventory_node.has_method("print_inventory"):
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
	
	var inventory_node: Node = p.get_node_or_null("Inventory")
	if not inventory_node:
		Debug.error("Player has no inventory")
		return
	
	var overflow: int = inventory_node.add_item(item_def, qty)
	
	if overflow == 0:
		Debug.ok("Added %dx %s to inventory" % [qty, item_def.display_name])
	else:
		var added := qty - overflow
		Debug.warn("Added %dx %s (overflow: %d)" % [added, item_def.display_name, overflow])
