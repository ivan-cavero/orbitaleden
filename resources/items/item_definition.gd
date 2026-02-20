class_name ItemDefinition
extends Resource
## Defines the properties of an item type.
##
## Create instances of this resource for each unique item in the game.
## Items can be materials, consumables, equipment, etc.

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
# Exports - Identity
# ─────────────────────────────────────────────────────────────────────────────

@export_group("Identity")
## Unique identifier (e.g., "scrap_metal", "medkit")
@export var id: String = ""
## Display name shown in UI
@export var display_name: String = ""
## Description shown in tooltips
@export_multiline var description: String = ""

# ─────────────────────────────────────────────────────────────────────────────
# Exports - Visuals
# ─────────────────────────────────────────────────────────────────────────────

@export_group("Visuals")
## Icon for inventory UI (recommended 64x64)
@export var icon: Texture2D
## 3D mesh scene for world display
@export var world_mesh: PackedScene
## Color tint for placeholder meshes
@export var color: Color = Color.WHITE

# ─────────────────────────────────────────────────────────────────────────────
# Exports - Properties
# ─────────────────────────────────────────────────────────────────────────────

@export_group("Properties")
## Item category
@export var category: Category = Category.MATERIAL
## Tech tier (affects when it's available)
@export var tier: Tier = Tier.TIER_1
## Maximum stack size (1 = not stackable)
@export_range(1, 999) var stack_size: int = 99
## Weight in kg (for future inventory weight limits)
@export var weight: float = 0.1

# ─────────────────────────────────────────────────────────────────────────────
# Exports - Usage
# ─────────────────────────────────────────────────────────────────────────────

@export_group("Usage")
## Can be used/consumed directly
@export var usable: bool = false
## Can be equipped in equipment slot
@export var equippable: bool = false

# ─────────────────────────────────────────────────────────────────────────────
# Exports - Consumable Effects (if usable)
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

## Returns true if this item has any restorative effects.
func has_consumable_effects() -> bool:
	return restore_health > 0 or restore_oxygen > 0 or restore_hunger > 0 or restore_thirst > 0


## Validates that required fields are set.
func is_valid() -> bool:
	return not id.is_empty() and not display_name.is_empty()
