class_name ItemStack
extends Resource
## Represents a stack of items (item type + quantity).
##
## Used in inventories, containers, and crafting recipes.

# ─────────────────────────────────────────────────────────────────────────────
# Signals
# ─────────────────────────────────────────────────────────────────────────────

signal quantity_changed(old_quantity: int, new_quantity: int)

# ─────────────────────────────────────────────────────────────────────────────
# Exports
# ─────────────────────────────────────────────────────────────────────────────

@export var item: ItemDefinition
@export_range(0, 999) var quantity: int = 1:
	set(value):
		var old := quantity
		quantity = clampi(value, 0, get_max_stack())
		if old != quantity:
			quantity_changed.emit(old, quantity)

# ─────────────────────────────────────────────────────────────────────────────
# Static Factory
# ─────────────────────────────────────────────────────────────────────────────

## Creates a new ItemStack with the given item and quantity.
static func create(p_item: ItemDefinition, p_quantity: int = 1) -> ItemStack:
	var stack := ItemStack.new()
	stack.item = p_item
	stack.quantity = p_quantity
	return stack

# ─────────────────────────────────────────────────────────────────────────────
# Queries
# ─────────────────────────────────────────────────────────────────────────────

## Returns true if this stack is empty or has no item.
func is_empty() -> bool:
	return item == null or quantity <= 0


## Returns true if this stack is at max capacity.
func is_full() -> bool:
	return quantity >= get_max_stack()


## Returns the maximum stack size for this item.
func get_max_stack() -> int:
	return item.stack_size if item else 1


## Returns how many more items can fit in this stack.
func get_space_remaining() -> int:
	return get_max_stack() - quantity


## Returns true if this stack can merge with another of the same item.
func can_merge_with(other: ItemStack) -> bool:
	if other == null or other.is_empty():
		return false
	return item == other.item and not is_full()

# ─────────────────────────────────────────────────────────────────────────────
# Operations
# ─────────────────────────────────────────────────────────────────────────────

## Adds quantity to this stack. Returns overflow (items that didn't fit).
func add(amount: int) -> int:
	var space := get_space_remaining()
	var to_add := mini(amount, space)
	quantity += to_add
	return amount - to_add


## Removes quantity from this stack. Returns actual amount removed.
func remove(amount: int) -> int:
	var to_remove := mini(amount, quantity)
	quantity -= to_remove
	return to_remove


## Merges another stack into this one. Returns leftover stack (or null if fully merged).
func merge_from(other: ItemStack) -> ItemStack:
	if not can_merge_with(other):
		return other
	
	var overflow := add(other.quantity)
	
	if overflow > 0:
		other.quantity = overflow
		return other
	
	return null


## Splits this stack, removing the specified amount and returning a new stack.
func split(amount: int) -> ItemStack:
	var to_split := mini(amount, quantity)
	if to_split <= 0:
		return null
	
	quantity -= to_split
	return ItemStack.create(item, to_split)


## Creates a duplicate of this stack.
func duplicate_stack() -> ItemStack:
	return ItemStack.create(item, quantity)
