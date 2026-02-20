class_name PlayerInventory
extends Node
## Manages the player's inventory and handles item pickup.
##
## Attach to the Player node. Listens for WorldItem pickup signals
## and adds items to the inventory.

# ─────────────────────────────────────────────────────────────────────────────
# Preloads
# ─────────────────────────────────────────────────────────────────────────────

const InventoryDataScript := preload("res://resources/inventory/inventory_data.gd")

# ─────────────────────────────────────────────────────────────────────────────
# Signals
# ─────────────────────────────────────────────────────────────────────────────

## Emitted when an item is picked up successfully.
signal item_picked_up(item: Resource, quantity: int)

## Emitted when pickup fails (inventory full).
signal pickup_failed(item: Resource, quantity: int)

# ─────────────────────────────────────────────────────────────────────────────
# Exports
# ─────────────────────────────────────────────────────────────────────────────

@export var inventory_size: int = 30

# ─────────────────────────────────────────────────────────────────────────────
# Public Variables
# ─────────────────────────────────────────────────────────────────────────────

## The inventory data resource.
var inventory: Resource

# ─────────────────────────────────────────────────────────────────────────────
# Lifecycle
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	inventory = InventoryDataScript.new()
	inventory.max_slots = inventory_size
	inventory._initialize_slots()
	
	# Connect to inventory changes for debugging
	inventory.inventory_changed.connect(_on_inventory_changed)

# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

## Tries to add an item to inventory. Returns overflow quantity.
func add_item(item: Resource, quantity: int = 1) -> int:
	var overflow: int = inventory.add_item(item, quantity)
	
	var added := quantity - overflow
	if added > 0:
		item_picked_up.emit(item, added)
		Debug.ok("Picked up %dx %s" % [added, item.display_name])
	
	if overflow > 0:
		pickup_failed.emit(item, overflow)
	
	return overflow


## Called when a WorldItem is picked up.
func on_world_item_picked_up(item: Resource, quantity: int, _player: Node) -> void:
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


## Quick check for console commands.
func has_item(item_id: String, quantity: int = 1) -> bool:
	# Find item by ID - this is inefficient but works for debugging
	for i in range(inventory.max_slots):
		var stack = inventory.get_slot(i)
		if stack and stack.item and stack.item.id == item_id:
			if inventory.get_item_count(stack.item) >= quantity:
				return true
	return false

# ─────────────────────────────────────────────────────────────────────────────
# Signal Handlers
# ─────────────────────────────────────────────────────────────────────────────

func _on_inventory_changed() -> void:
	# Debug output when inventory changes
	pass  # Will be useful for UI updates later
