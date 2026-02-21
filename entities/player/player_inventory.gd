class_name PlayerInventory
extends Node
## Manages the player's inventory and handles item pickup.
##
## Attach to the Player node. Listens for WorldItem pickup signals
## and adds items to the inventory.

# ─────────────────────────────────────────────────────────────────────────────
# Signals
# ─────────────────────────────────────────────────────────────────────────────

## Emitted when an item is picked up successfully.
signal item_picked_up(item: ItemDefinition, quantity: int)

## Emitted when pickup fails (inventory full).
signal pickup_failed(item: ItemDefinition, quantity: int)

# ─────────────────────────────────────────────────────────────────────────────
# Exports
# ─────────────────────────────────────────────────────────────────────────────

@export var inventory_size: int = 30
@export var hotbar_size: int = 8

# ─────────────────────────────────────────────────────────────────────────────
# Public Variables
# ─────────────────────────────────────────────────────────────────────────────

## The main inventory data resource.
var inventory: InventoryData

## The hotbar data resource (separate 8-slot inventory).
var hotbar: InventoryData

# ─────────────────────────────────────────────────────────────────────────────
# Lifecycle
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	inventory = InventoryData.new()
	inventory.max_slots = inventory_size
	inventory._initialize_slots()

	hotbar = InventoryData.new()
	hotbar.max_slots = hotbar_size
	hotbar._initialize_slots()

# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

## Tries to add an item to inventory. Returns overflow quantity.
func add_item(item: ItemDefinition, quantity: int = 1) -> int:
	var overflow: int = inventory.add_item(item, quantity)

	var added := quantity - overflow
	if added > 0:
		item_picked_up.emit(item, added)
		Debug.ok("Picked up %dx %s" % [added, item.display_name])

	if overflow > 0:
		pickup_failed.emit(item, overflow)

	return overflow


## Called when a WorldItem is picked up.
func on_world_item_picked_up(item: ItemDefinition, quantity: int, _player: Node) -> void:
	if item == null:
		Debug.error("PlayerInventory: Invalid item definition")
		return

	var overflow := add_item(item, quantity)

	if overflow > 0:
		Debug.warn("Inventory full! %d %s dropped." % [overflow, item.display_name])
		# TODO: Spawn dropped items back into world


## Prints inventory contents to console.
func print_inventory() -> void:
	var summary: String = inventory.get_summary()
	for line in summary.split("\n"):
		Debug.info(line)


## Checks whether the inventory contains at least [quantity] of the given item ID.
func has_item(item_id: String, quantity: int = 1) -> bool:
	var item_definition := ItemDatabase.get_item(item_id)
	if item_definition == null:
		return false
	return inventory.has_item(item_definition, quantity)
