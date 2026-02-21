class_name ItemDefinition
extends Resource
## Defines the properties of an item type.
##
## Create one .tres resource per unique item in res://resources/items/definitions/.
## The ItemDatabase autoload will register it automatically at runtime.
## All fields are configurable from the Godot Inspector.

# ─────────────────────────────────────────────────────────────────────────────
# Enums
# ─────────────────────────────────────────────────────────────────────────────

enum Category {
	MATERIAL,    ## Raw materials and components
	CONSUMABLE,  ## Food, medicine, oxygen
	TOOL,        ## Usable tools
	EQUIPMENT,   ## Wearable gear
	BUILDABLE,   ## Placeable structures/machines
}

enum Tier {
	TIER_1 = 1,  ## Basic, early game
	TIER_2 = 2,  ## Intermediate
	TIER_3 = 3,  ## Advanced
	TIER_4 = 4,  ## End-game
}

# ─────────────────────────────────────────────────────────────────────────────
# Category Display Names (static lookup)
# ─────────────────────────────────────────────────────────────────────────────

## Human-readable names indexed by Category enum value.
const CATEGORY_NAMES: Dictionary = {
	Category.MATERIAL:   "Material",
	Category.CONSUMABLE: "Consumable",
	Category.TOOL:       "Tool",
	Category.EQUIPMENT:  "Equipment",
	Category.BUILDABLE:  "Buildable",
}

## Returns the display name for a Category enum value.
static func get_category_name(cat: Category) -> String:
	return CATEGORY_NAMES.get(cat, "Unknown")

# ─────────────────────────────────────────────────────────────────────────────
# Exports - Identity
# ─────────────────────────────────────────────────────────────────────────────

@export_group("Identity")
## Unique identifier (e.g., "scrap_metal", "medkit").
## Must match the .tres filename (without extension).
@export var id: String = ""
## Display name shown in UI
@export var display_name: String = ""
## Description shown in tooltips
@export_multiline var description: String = ""

# ─────────────────────────────────────────────────────────────────────────────
# Exports - Visuals
# ─────────────────────────────────────────────────────────────────────────────

@export_group("Visuals")
## Icon for inventory / hotbar (recommended 64x64)
@export var icon: Texture2D
## 3D mesh scene for world display (dropped items, held items)
@export var world_mesh: PackedScene
## Color tint used for placeholder icons when no icon is assigned
@export var color: Color = Color.WHITE

# ─────────────────────────────────────────────────────────────────────────────
# Exports - Properties
# ─────────────────────────────────────────────────────────────────────────────

@export_group("Properties")
## Item category (determines available actions and sorting)
@export var category: Category = Category.MATERIAL
## Tech tier (affects when it becomes available)
@export var tier: Tier = Tier.TIER_1
## Maximum stack size (1 = not stackable)
@export_range(1, 999) var stack_size: int = 99
## Weight in kg (for future inventory weight limits)
@export var weight: float = 0.1

# ─────────────────────────────────────────────────────────────────────────────
# Exports - Usage
# ─────────────────────────────────────────────────────────────────────────────

@export_group("Usage")
## Can be used/consumed from the inventory (right-click menu)
@export var usable: bool = false
## Label shown on the context-menu "Use" button (e.g. "Eat", "Drink", "Apply").
## Leave empty to use the default "Use".
@export var use_action_label: String = ""
## Can be equipped in an equipment slot
@export var equippable: bool = false

# ─────────────────────────────────────────────────────────────────────────────
# Exports - Consumable Effects
# ─────────────────────────────────────────────────────────────────────────────

@export_group("Consumable Effects")
## Health restored on use
@export var restore_health: float = 0.0
## Oxygen restored on use
@export var restore_oxygen: float = 0.0
## Hunger restored on use
@export var restore_hunger: float = 0.0
## Thirst restored on use
@export var restore_thirst: float = 0.0

# ─────────────────────────────────────────────────────────────────────────────
# Methods
# ─────────────────────────────────────────────────────────────────────────────

## Returns the action label for the "Use" button in the context menu.
## Falls back to "Use" when no custom label is set.
func get_use_label() -> String:
	if not use_action_label.is_empty():
		return use_action_label
	return "Use"


## Returns true if this item has any restorative effects.
func has_consumable_effects() -> bool:
	return restore_health > 0 or restore_oxygen > 0 or restore_hunger > 0 or restore_thirst > 0


## Validates that required fields are set.
func is_valid() -> bool:
	return not id.is_empty() and not display_name.is_empty()


## Consumes this item, applying any effects to the player.
## In Phase 3 this is a stub: effects are applied in Phase 4 when PlayerStats exist.
## [param player] — the player node (unused until Phase 4).
func use(_player: Node) -> void:
	var label := get_use_label()
	if has_consumable_effects():
		var parts: Array[String] = []
		if restore_health  > 0: parts.append("+%.0f HP"      % restore_health)
		if restore_oxygen  > 0: parts.append("+%.0f O2"      % restore_oxygen)
		if restore_hunger  > 0: parts.append("+%.0f Hunger"  % restore_hunger)
		if restore_thirst  > 0: parts.append("+%.0f Thirst"  % restore_thirst)
		Debug.ok("%s %s (%s)" % [label, display_name, ", ".join(parts)])
	else:
		Debug.info("%s %s" % [label, display_name])
