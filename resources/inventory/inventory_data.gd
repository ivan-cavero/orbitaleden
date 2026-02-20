class_name InventoryData
extends Resource
## Container for item storage with fixed slots.
##
## Used for player inventory, chests, machines, etc.
## Handles stacking, overflow, and slot management.

# ─────────────────────────────────────────────────────────────────────────────
# Signals
# ─────────────────────────────────────────────────────────────────────────────

## Emitted when any slot changes (add, remove, swap).
signal inventory_changed()

## Emitted when a specific slot changes.
signal slot_changed(slot_index: int)

# ─────────────────────────────────────────────────────────────────────────────
# Exports
# ─────────────────────────────────────────────────────────────────────────────

@export var max_slots: int = 30

# ─────────────────────────────────────────────────────────────────────────────
# Internal Data
# ─────────────────────────────────────────────────────────────────────────────

## Array of ItemStack (null = empty slot)
var _slots: Array = []

# ─────────────────────────────────────────────────────────────────────────────
# Initialization
# ─────────────────────────────────────────────────────────────────────────────

func _init() -> void:
	_initialize_slots()


func _initialize_slots() -> void:
	_slots.clear()
	_slots.resize(max_slots)
	for i in range(max_slots):
		_slots[i] = null

# ─────────────────────────────────────────────────────────────────────────────
# Public API - Adding Items
# ─────────────────────────────────────────────────────────────────────────────

## Adds an item to the inventory. Returns overflow quantity (items that didn't fit).
func add_item(item: ItemDefinition, quantity: int = 1) -> int:
	if item == null or quantity <= 0:
		return quantity
	
	var remaining := quantity
	
	# First, try to stack with existing slots
	remaining = _add_to_existing_stacks(item, remaining)
	
	# Then, fill empty slots
	if remaining > 0:
		remaining = _add_to_empty_slots(item, remaining)
	
	if remaining < quantity:
		inventory_changed.emit()
	
	return remaining


## Adds an ItemStack to the inventory. Returns overflow as a new stack (or null).
func add_stack(stack: ItemStack) -> ItemStack:
	if stack == null or stack.is_empty():
		return null
	
	var overflow := add_item(stack.item, stack.quantity)
	
	if overflow > 0:
		return ItemStack.create(stack.item, overflow)
	return null

# ─────────────────────────────────────────────────────────────────────────────
# Public API - Removing Items
# ─────────────────────────────────────────────────────────────────────────────

## Removes items from inventory. Returns true if successful.
func remove_item(item: ItemDefinition, quantity: int = 1) -> bool:
	if not has_item(item, quantity):
		return false
	
	var remaining := quantity
	
	# Remove from slots (last to first to preserve order)
	for i in range(max_slots - 1, -1, -1):
		if remaining <= 0:
			break
		
		var slot := _slots[i] as ItemStack
		if slot and slot.item == item:
			var removed := slot.remove(remaining)
			remaining -= removed
			
			if slot.is_empty():
				_slots[i] = null
			
			slot_changed.emit(i)
	
	inventory_changed.emit()
	return true


## Clears a specific slot. Returns the removed stack (or null).
func clear_slot(slot_index: int) -> ItemStack:
	if not _is_valid_slot(slot_index):
		return null
	
	var stack := _slots[slot_index] as ItemStack
	_slots[slot_index] = null
	
	if stack:
		slot_changed.emit(slot_index)
		inventory_changed.emit()
	
	return stack

# ─────────────────────────────────────────────────────────────────────────────
# Public API - Queries
# ─────────────────────────────────────────────────────────────────────────────

## Returns true if inventory contains at least the specified quantity.
func has_item(item: ItemDefinition, quantity: int = 1) -> bool:
	return get_item_count(item) >= quantity


## Returns total count of an item across all slots.
func get_item_count(item: ItemDefinition) -> int:
	var count := 0
	for slot in _slots:
		if slot and slot.item == item:
			count += slot.quantity
	return count


## Finds first slot containing the item. Returns -1 if not found.
func find_slot(item: ItemDefinition) -> int:
	for i in range(max_slots):
		var slot := _slots[i] as ItemStack
		if slot and slot.item == item:
			return i
	return -1


## Finds first empty slot. Returns -1 if inventory is full.
func find_empty_slot() -> int:
	for i in range(max_slots):
		if _slots[i] == null:
			return i
	return -1


## Returns the stack at a slot index (or null).
func get_slot(slot_index: int) -> ItemStack:
	if not _is_valid_slot(slot_index):
		return null
	return _slots[slot_index]


## Returns true if the inventory is completely full.
func is_full() -> bool:
	return find_empty_slot() == -1


## Returns true if the inventory is completely empty.
func is_empty() -> bool:
	for slot in _slots:
		if slot and not slot.is_empty():
			return false
	return true


## Returns count of used slots.
func get_used_slot_count() -> int:
	var count := 0
	for slot in _slots:
		if slot and not slot.is_empty():
			count += 1
	return count

# ─────────────────────────────────────────────────────────────────────────────
# Public API - Slot Operations
# ─────────────────────────────────────────────────────────────────────────────

## Sets a slot directly. Use with caution.
func set_slot(slot_index: int, stack: ItemStack) -> void:
	if not _is_valid_slot(slot_index):
		return
	
	_slots[slot_index] = stack
	slot_changed.emit(slot_index)
	inventory_changed.emit()


## Swaps two slots.
func swap_slots(from_index: int, to_index: int) -> void:
	if not _is_valid_slot(from_index) or not _is_valid_slot(to_index):
		return
	
	var temp = _slots[from_index]
	_slots[from_index] = _slots[to_index]
	_slots[to_index] = temp
	
	slot_changed.emit(from_index)
	slot_changed.emit(to_index)
	inventory_changed.emit()


## Tries to merge from_slot into to_slot. Returns true if any items moved.
func merge_slots(from_index: int, to_index: int) -> bool:
	if not _is_valid_slot(from_index) or not _is_valid_slot(to_index):
		return false
	
	var from_stack := _slots[from_index] as ItemStack
	var to_stack := _slots[to_index] as ItemStack
	
	if from_stack == null or from_stack.is_empty():
		return false
	
	# If destination is empty, just move
	if to_stack == null:
		_slots[to_index] = from_stack
		_slots[from_index] = null
		slot_changed.emit(from_index)
		slot_changed.emit(to_index)
		inventory_changed.emit()
		return true
	
	# Try to merge
	if not to_stack.can_merge_with(from_stack):
		return false
	
	var leftover := to_stack.merge_from(from_stack)
	_slots[from_index] = leftover
	
	slot_changed.emit(from_index)
	slot_changed.emit(to_index)
	inventory_changed.emit()
	return true

# ─────────────────────────────────────────────────────────────────────────────
# Public API - Utility
# ─────────────────────────────────────────────────────────────────────────────

## Returns a summary of inventory contents for debugging.
func get_summary() -> String:
	var lines: Array[String] = []
	lines.append("Inventory (%d/%d slots):" % [get_used_slot_count(), max_slots])
	
	for i in range(max_slots):
		var slot := _slots[i] as ItemStack
		if slot and not slot.is_empty():
			lines.append("  [%d] %s x%d" % [i, slot.item.display_name, slot.quantity])
	
	if lines.size() == 1:
		lines.append("  (empty)")
	
	return "\n".join(lines)


## Clears the entire inventory.
func clear() -> void:
	for i in range(max_slots):
		_slots[i] = null
	inventory_changed.emit()

# ─────────────────────────────────────────────────────────────────────────────
# Private Helpers
# ─────────────────────────────────────────────────────────────────────────────

func _is_valid_slot(index: int) -> bool:
	return index >= 0 and index < max_slots


func _add_to_existing_stacks(item: ItemDefinition, quantity: int) -> int:
	var remaining := quantity
	
	for i in range(max_slots):
		if remaining <= 0:
			break
		
		var slot := _slots[i] as ItemStack
		if slot and slot.item == item and not slot.is_full():
			var overflow := slot.add(remaining)
			remaining = overflow
			slot_changed.emit(i)
	
	return remaining


func _add_to_empty_slots(item: ItemDefinition, quantity: int) -> int:
	var remaining := quantity
	
	while remaining > 0:
		var empty_idx := find_empty_slot()
		if empty_idx == -1:
			break
		
		var to_add := mini(remaining, item.stack_size)
		_slots[empty_idx] = ItemStack.create(item, to_add)
		remaining -= to_add
		slot_changed.emit(empty_idx)
	
	return remaining
