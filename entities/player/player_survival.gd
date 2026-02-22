class_name PlayerSurvival
extends Node
## Survival component for the player.
##
## Owns the PlayerStats resource and drives stat drain each frame.
## Drain rates scale with movement (walking ×1.5, running ×2.5).
## Jumping costs stamina directly.
##
## Stat effects:
##   - Sin comida            → vida baja lento, stamina no regenera
##   - Sin comida + sin sed  → vida baja más rápido, velocidad reducida
##   - Sin oxígeno           → 30s de fade-a-negro + slow-mo → inconsciencia
##
## Phase 4.5 will wire item consumption (restore_health, etc.).

# ─────────────────────────────────────────────────────────────────────────────
# Signals
# ─────────────────────────────────────────────────────────────────────────────

## Forwarded from PlayerStats.stat_changed.
signal stat_changed(stat_name: String, old_value: float, new_value: float)

## Forwarded from PlayerStats.stat_depleted.
signal stat_depleted(stat_name: String)

## Emitted when oxygen hits 0. Payload: seconds_remaining in [0, unconscious_duration].
## ScreenEffects listens to this to drive the fade-to-black.
signal unconscious_tick(progress: float)

## Emitted when the player loses consciousness (oxygen at 0 for unconscious_duration).
signal unconscious

## Emitted when oxygen is restored above 0 during the unconscious countdown.
signal consciousness_restored

## Emitted once when health reaches 0. Payload: cause string.
signal died(cause: String)

# ─────────────────────────────────────────────────────────────────────────────
# Exports — drain rates (base = completely still)
# ─────────────────────────────────────────────────────────────────────────────

@export_group("Drain Rates (base, still)")
## Oxygen per second at rest. Default: 0.556 → 180s (3 min) to empty.
@export var oxygen_drain_rate: float = 0.556
## Hunger per second at rest. Default: 0.167 → 600s (10 min) to empty.
@export var hunger_drain_rate: float = 0.167
## Thirst per second at rest. Default: 0.238 → 420s (7 min) to empty.
@export var thirst_drain_rate: float = 0.238

@export_group("Movement Drain Multipliers")
## Extra drain multiplier while walking (horizontal speed > 0).
@export var walk_drain_mult: float = 1.5
## Extra drain multiplier while sprinting.
@export var sprint_drain_mult: float = 2.5

@export_group("Stamina")
## Stamina drained per second while sprinting.
@export var stamina_sprint_drain: float = 10.0
## Stamina cost per jump.
@export var stamina_jump_cost: float = 10.0
## Stamina recovered per second while on floor and not sprinting.
@export var stamina_regen_rate: float = 5.0
## Stamina recovered per second while crouching.
@export var stamina_crouch_regen: float = 8.0

@export_group("Stat Effects")
## Health drained per second when hunger = 0.
@export var starvation_drain: float = 0.5
## Extra health drained per second when both hunger AND thirst = 0.
@export var dehydration_extra_drain: float = 1.0
## Speed multiplier when thirst = 0 AND hunger = 0.
@export var combined_depleted_speed_penalty: float = 0.75
## Seconds at 0 oxygen before the player loses consciousness.
@export var unconscious_duration: float = 30.0

@export_group("Drain Toggle")
## When false all passive drains are paused (useful for testing / cutscenes).
@export var draining_enabled: bool = true

# ─────────────────────────────────────────────────────────────────────────────
# Public state
# ─────────────────────────────────────────────────────────────────────────────

## The underlying PlayerStats resource. Untyped to avoid class load-order issues.
var stats = null

## True while the player is actively losing stamina to a sprint this frame.
var is_sprinting: bool = false

## Seconds since oxygen hit 0. 0 when oxygen > 0.
var oxygen_depleted_timer: float = 0.0

## True while the player is unconscious (oxygen at 0 for full unconscious_duration).
var is_unconscious: bool = false

## True once the player has died (health = 0). Prevents repeated died emissions.
var is_dead: bool = false

# ─────────────────────────────────────────────────────────────────────────────
# Private
# ─────────────────────────────────────────────────────────────────────────────

var _controller: Node = null

# ─────────────────────────────────────────────────────────────────────────────
# Lifecycle
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	var StatsScript = load("res://resources/survival/player_stats.gd")
	stats = StatsScript.new()
	stats.stat_changed.connect(_on_stat_changed)
	stats.stat_depleted.connect(_on_stat_depleted)

	_controller = get_parent()
	if not is_instance_valid(_controller) or not _controller.has_method("get_debug_snapshot"):
		Debug.warn("PlayerSurvival: parent is not a PlayerController")
		_controller = null
	else:
		# Hook jump signal for stamina cost.
		if _controller.has_signal("jumped"):
			_controller.jumped.connect(_on_player_jumped)

	Debug.info("PlayerSurvival ready — O2 %.3f/s  hunger %.3f/s  thirst %.3f/s" % [
		oxygen_drain_rate, hunger_drain_rate, thirst_drain_rate
	])


func _process(delta: float) -> void:
	if stats == null:
		return

	if draining_enabled:
		_drain_stats(delta)
		_process_stamina(delta)

	_apply_stat_effects(delta)


# ─────────────────────────────────────────────────────────────────────────────
# Drain logic
# ─────────────────────────────────────────────────────────────────────────────

func _drain_stats(delta: float) -> void:
	# Determine movement multiplier from controller snapshot.
	var mult := _get_drain_multiplier()

	# Oxygen doesn't scale with movement (suit life support is independent).
	stats.modify_stat("oxygen", -oxygen_drain_rate * delta)

	# Hunger and thirst scale with physical activity.
	stats.modify_stat("hunger", -hunger_drain_rate * mult * delta)
	stats.modify_stat("thirst", -thirst_drain_rate * mult * delta)


func _get_drain_multiplier() -> float:
	if not is_instance_valid(_controller):
		return 1.0
	var snap: Dictionary = _controller.get_debug_snapshot()
	if bool(snap.get("sprinting", false)):
		return sprint_drain_mult
	if bool(snap.get("is_moving", false)):
		return walk_drain_mult
	return 1.0


func _process_stamina(delta: float) -> void:
	var sprinting := false
	var crouching := false
	var on_floor  := true

	if is_instance_valid(_controller):
		var snap: Dictionary = _controller.get_debug_snapshot()
		sprinting = bool(snap.get("sprinting", false))
		crouching = bool(snap.get("crouching", false))
		on_floor  = bool(snap.get("on_floor",  true))

	is_sprinting = sprinting

	if sprinting and stats.get_stat("stamina") > 0.0:
		stats.modify_stat("stamina", -stamina_sprint_drain * delta)
	elif not sprinting and on_floor and stats.get_stat("stamina") < stats.get_stat_max("stamina"):
		# No regen when starving.
		if stats.is_depleted("hunger"):
			return
		var regen := stamina_crouch_regen if crouching else stamina_regen_rate
		stats.modify_stat("stamina", regen * delta)


# ─────────────────────────────────────────────────────────────────────────────
# Stat effects
# ─────────────────────────────────────────────────────────────────────────────

func _apply_stat_effects(delta: float) -> void:
	_apply_oxygen_effects(delta)
	_apply_hunger_thirst_effects(delta)
	_check_death()


func _apply_oxygen_effects(delta: float) -> void:
	if stats.is_depleted("oxygen"):
		oxygen_depleted_timer += delta
		var progress := clampf(oxygen_depleted_timer / unconscious_duration, 0.0, 1.0)
		unconscious_tick.emit(progress)

		# Speed slows progressively as we approach unconsciousness.
		if is_instance_valid(_controller) and "survival_speed_multiplier" in _controller:
			_controller.survival_speed_multiplier = 1.0 - progress * 0.9  # 100% → 10%

		if oxygen_depleted_timer >= unconscious_duration and not is_unconscious:
			is_unconscious = true
			unconscious.emit()
			Debug.warn("PlayerSurvival: player lost consciousness (oxygen depleted)")
	else:
		# Oxygen restored — cancel unconscious countdown.
		if oxygen_depleted_timer > 0.0:
			oxygen_depleted_timer = 0.0
			is_unconscious = false
			consciousness_restored.emit()
			# Restore speed (hunger/thirst may still penalise it below).
			if is_instance_valid(_controller) and "survival_speed_multiplier" in _controller:
				_controller.survival_speed_multiplier = 1.0


func _apply_hunger_thirst_effects(delta: float) -> void:
	var hunger_depleted: bool = stats.is_depleted("hunger")
	var thirst_depleted: bool = stats.is_depleted("thirst")

	# ── Speed penalty ─────────────────────────────────────────────────────────
	# Only if oxygen is OK (oxygen already handles speed via _apply_oxygen_effects).
	if not bool(stats.is_depleted("oxygen")):
		if is_instance_valid(_controller) and "survival_speed_multiplier" in _controller:
			if hunger_depleted and thirst_depleted:
				_controller.survival_speed_multiplier = combined_depleted_speed_penalty
			else:
				_controller.survival_speed_multiplier = 1.0

	# ── Health drain ─────────────────────────────────────────────────────────
	# Respect god mode.
	var in_god_mode: bool = is_instance_valid(_controller) and bool(_controller.get("god_mode"))
	if in_god_mode:
		return

	if hunger_depleted:
		var health_drain: float = starvation_drain
		if thirst_depleted:
			health_drain += dehydration_extra_drain
		stats.modify_stat("health", -health_drain * delta)


# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

func restore(stat_name: String, amount: float) -> void:
	if stats == null:
		return
	stats.modify_stat(stat_name, absf(amount))


func drain(stat_name: String, amount: float) -> void:
	if stats == null:
		return
	stats.modify_stat(stat_name, -absf(amount))


func set_stat(stat_name: String, value: float) -> void:
	if stats == null:
		return
	stats.set_stat(stat_name, value)


func get_debug_snapshot() -> Dictionary:
	if stats == null:
		return {}
	var snap: Dictionary = stats.get_snapshot()
	snap["_draining"]          = draining_enabled
	snap["_sprinting"]         = is_sprinting
	snap["_o2_timer"]          = oxygen_depleted_timer
	snap["_unconscious"]       = is_unconscious
	return snap

# ─────────────────────────────────────────────────────────────────────────────
# Signal handlers
# ─────────────────────────────────────────────────────────────────────────────

func _on_stat_changed(stat_name: String, old_value: float, new_value: float) -> void:
	stat_changed.emit(stat_name, old_value, new_value)


func _on_stat_depleted(stat_name: String) -> void:
	stat_depleted.emit(stat_name)


func _on_player_jumped() -> void:
	if stats == null:
		return
	stats.modify_stat("stamina", -stamina_jump_cost)


# ─────────────────────────────────────────────────────────────────────────────
# Death handling
# ─────────────────────────────────────────────────────────────────────────────

func _check_death() -> void:
	if is_dead or stats == null:
		return
	if not stats.is_depleted("health"):
		return
	is_dead = true
	# Determine cause of death.
	var cause := _get_death_cause()
	Debug.warn("PlayerSurvival: player died — %s" % cause)
	died.emit(cause)


func _get_death_cause() -> String:
	if stats == null:
		return "Unknown"
	if is_unconscious:
		return "Suffocation"
	if stats.is_depleted("hunger") and stats.is_depleted("thirst"):
		return "Starvation and Dehydration"
	if stats.is_depleted("hunger"):
		return "Starvation"
	if stats.is_depleted("thirst"):
		return "Dehydration"
	return "Injuries"


## Resets all stats to maximum and clears death/unconscious state.
## Called on respawn.
func reset_for_respawn() -> void:
	if stats != null:
		stats.reset_all()
	is_dead          = false
	is_unconscious   = false
	oxygen_depleted_timer = 0.0
	# Reset time_scale in case the player died during the unconscious fade.
	Engine.time_scale = 1.0
	if is_instance_valid(_controller) and "survival_speed_multiplier" in _controller:
		_controller.survival_speed_multiplier = 1.0
