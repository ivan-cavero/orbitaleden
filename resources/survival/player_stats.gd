class_name PlayerStats
extends Resource
## Survival statistics for the player.
##
## Holds health, oxygen, hunger, thirst, sanity and stamina.
## Each stat has a current value (0–max) and a max value.
## All writes go through set_stat() to guarantee signals fire consistently.

# ─────────────────────────────────────────────────────────────────────────────
# Signals
# ─────────────────────────────────────────────────────────────────────────────

## Emitted whenever any stat value changes.
## old_value and new_value are both clamped to [0, max].
signal stat_changed(stat_name: String, old_value: float, new_value: float)

## Emitted when a stat reaches 0 for the first time in a depletion event.
signal stat_depleted(stat_name: String)

# ─────────────────────────────────────────────────────────────────────────────
# Exports — max values (configurable per game mode / difficulty)
# ─────────────────────────────────────────────────────────────────────────────

@export_group("Health")
@export var health_max: float = 100.0

@export_group("Oxygen")
@export var oxygen_max: float = 100.0

@export_group("Hunger")
## 100 = full, 0 = starving
@export var hunger_max: float = 100.0

@export_group("Thirst")
## 100 = hydrated, 0 = dehydrated
@export var thirst_max: float = 100.0

@export_group("Sanity")
@export var sanity_max: float = 100.0

@export_group("Stamina")
@export var stamina_max: float = 100.0

# ─────────────────────────────────────────────────────────────────────────────
# Internal state
# ─────────────────────────────────────────────────────────────────────────────

var health: float = 100.0
var oxygen: float = 100.0
var hunger: float = 100.0
var thirst: float = 100.0
var sanity: float = 100.0
var stamina: float = 100.0

## Tracks which stats are currently at 0 so stat_depleted fires only once
## per depletion event (resets when the stat rises above 0 again).
var _depleted: Dictionary = {}

# ─────────────────────────────────────────────────────────────────────────────
# Initialization
# ─────────────────────────────────────────────────────────────────────────────

func _init() -> void:
	reset_all()


## Resets all stats to their maximum values.
func reset_all() -> void:
	health  = health_max
	oxygen  = oxygen_max
	hunger  = hunger_max
	thirst  = thirst_max
	sanity  = sanity_max
	stamina = stamina_max

# ─────────────────────────────────────────────────────────────────────────────
# Public API — generic read/write
# ─────────────────────────────────────────────────────────────────────────────

## Returns the current value of a stat by name.
## Returns -1.0 if the stat name is unknown.
func get_stat(stat_name: String) -> float:
	match stat_name:
		"health":  return health
		"oxygen":  return oxygen
		"hunger":  return hunger
		"thirst":  return thirst
		"sanity":  return sanity
		"stamina": return stamina
	return -1.0


## Returns the maximum value of a stat by name.
## Returns -1.0 if the stat name is unknown.
func get_stat_max(stat_name: String) -> float:
	match stat_name:
		"health":  return health_max
		"oxygen":  return oxygen_max
		"hunger":  return hunger_max
		"thirst":  return thirst_max
		"sanity":  return sanity_max
		"stamina": return stamina_max
	return -1.0


## Sets a stat to an absolute value (clamped to [0, max]).
## Emits stat_changed, and stat_depleted when hitting 0.
func set_stat(stat_name: String, value: float) -> void:
	var max_val := get_stat_max(stat_name)
	if max_val < 0.0:
		push_warning("PlayerStats.set_stat: unknown stat '%s'" % stat_name)
		return

	var old_val := get_stat(stat_name)
	var new_val := clampf(value, 0.0, max_val)

	if is_equal_approx(old_val, new_val):
		return

	_write_stat(stat_name, new_val)
	stat_changed.emit(stat_name, old_val, new_val)

	# Fire stat_depleted only once per depletion event.
	# Resets (allowing re-fire) when the stat rises above 0.
	if new_val <= 0.0 and old_val > 0.0 and not _depleted.get(stat_name, false):
		_depleted[stat_name] = true
		stat_depleted.emit(stat_name)
	elif new_val > 0.0:
		_depleted[stat_name] = false


## Applies a delta to a stat (positive = restore, negative = drain).
func modify_stat(stat_name: String, delta: float) -> void:
	set_stat(stat_name, get_stat(stat_name) + delta)

# ─────────────────────────────────────────────────────────────────────────────
# Public API — convenience per-stat methods
# ─────────────────────────────────────────────────────────────────────────────

func set_health(value: float)  -> void: set_stat("health",  value)
func set_oxygen(value: float)  -> void: set_stat("oxygen",  value)
func set_hunger(value: float)  -> void: set_stat("hunger",  value)
func set_thirst(value: float)  -> void: set_stat("thirst",  value)
func set_sanity(value: float)  -> void: set_stat("sanity",  value)
func set_stamina(value: float) -> void: set_stat("stamina", value)

func modify_health(delta: float)  -> void: modify_stat("health",  delta)
func modify_oxygen(delta: float)  -> void: modify_stat("oxygen",  delta)
func modify_hunger(delta: float)  -> void: modify_stat("hunger",  delta)
func modify_thirst(delta: float)  -> void: modify_stat("thirst",  delta)
func modify_sanity(delta: float)  -> void: modify_stat("sanity",  delta)
func modify_stamina(delta: float) -> void: modify_stat("stamina", delta)

# ─────────────────────────────────────────────────────────────────────────────
# Public API — queries
# ─────────────────────────────────────────────────────────────────────────────

## Returns the stat as a ratio in [0, 1]. Returns 0 for unknown stats.
func get_ratio(stat_name: String) -> float:
	var max_val := get_stat_max(stat_name)
	if max_val <= 0.0:
		return 0.0
	return get_stat(stat_name) / max_val


## Returns true if the stat is at zero.
func is_depleted(stat_name: String) -> bool:
	return get_stat(stat_name) <= 0.0


## Returns true if the stat is at its maximum.
func is_full(stat_name: String) -> bool:
	return is_equal_approx(get_stat(stat_name), get_stat_max(stat_name))


## Returns a snapshot Dictionary suitable for debugging / serialization.
func get_snapshot() -> Dictionary:
	return {
		"health":  [health,  health_max],
		"oxygen":  [oxygen,  oxygen_max],
		"hunger":  [hunger,  hunger_max],
		"thirst":  [thirst,  thirst_max],
		"sanity":  [sanity,  sanity_max],
		"stamina": [stamina, stamina_max],
	}

# ─────────────────────────────────────────────────────────────────────────────
# Private helpers
# ─────────────────────────────────────────────────────────────────────────────

func _write_stat(stat_name: String, value: float) -> void:
	match stat_name:
		"health":  health  = value
		"oxygen":  oxygen  = value
		"hunger":  hunger  = value
		"thirst":  thirst  = value
		"sanity":  sanity  = value
		"stamina": stamina = value
