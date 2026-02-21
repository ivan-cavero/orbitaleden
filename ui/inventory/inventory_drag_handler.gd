class_name InventoryDragHandler
extends RefCounted
## Manages all drag-and-drop logic for the inventory and hotbar.
##
## Tracks drag state, provides methods to start/drop/cancel drags,
## and manages the visual drag preview on the overlay layer.

# ─────────────────────────────────────────────────────────────────────────────
# Signals
# ─────────────────────────────────────────────────────────────────────────────

## Emitted when a drag ends (success or cancel) so the coordinator can refresh.
signal drag_ended()

# ─────────────────────────────────────────────────────────────────────────────
# State
# ─────────────────────────────────────────────────────────────────────────────

var is_dragging := false
var drag_from_index: int = -1
var drag_from_hotbar: bool = false
var drag_stack: ItemStack = null

## Set true when a slot handles the drop (prevents _input from also ending drag).
var drag_handled: bool = false

## Ignore the mouse-up from the click that started the drag.
var drag_just_started: bool = false

# ─────────────────────────────────────────────────────────────────────────────
# External Refs (set by coordinator)
# ─────────────────────────────────────────────────────────────────────────────

var _drag_preview: TextureRect
var _drag_quantity_label: Label
var _inventory_data: InventoryData
var _hotbar_data: InventoryData
var _mouse_position_source: Control  ## Used for get_global_mouse_position()

# ─────────────────────────────────────────────────────────────────────────────
# Setup
# ─────────────────────────────────────────────────────────────────────────────

func setup(
	drag_preview: TextureRect,
	drag_quantity_label: Label,
	inventory_data: InventoryData,
	hotbar_data: InventoryData,
	mouse_position_source: Control
) -> void:
	_drag_preview = drag_preview
	_drag_quantity_label = drag_quantity_label
	_inventory_data = inventory_data
	_hotbar_data = hotbar_data
	_mouse_position_source = mouse_position_source

# ─────────────────────────────────────────────────────────────────────────────
# Start Drag
# ─────────────────────────────────────────────────────────────────────────────

## Starts a drag from an inventory slot.
func start_from_inventory(slot_index: int) -> void:
	if not _inventory_data:
		return
	var stack := _inventory_data.get_slot(slot_index)
	if stack == null or stack.is_empty():
		return

	is_dragging = true
	drag_from_index = slot_index
	drag_from_hotbar = false
	drag_stack = stack.duplicate_stack()
	drag_just_started = true

	_inventory_data.clear_slot(slot_index)
	_show_preview()


## Starts a drag from a hotbar slot.
func start_from_hotbar(hotbar_index: int) -> void:
	if not _hotbar_data:
		return
	var stack := _hotbar_data.get_slot(hotbar_index)
	if stack == null or stack.is_empty():
		return

	is_dragging = true
	drag_from_index = hotbar_index
	drag_from_hotbar = true
	drag_stack = stack.duplicate_stack()
	drag_just_started = true

	_hotbar_data.clear_slot(hotbar_index)
	_show_preview()


## Starts a drag with an already-split stack (from split menu).
func start_with_split_stack(source_index: int, split_stack: ItemStack) -> void:
	is_dragging = true
	drag_from_index = source_index
	drag_from_hotbar = false
	drag_stack = split_stack
	drag_just_started = true
	_show_preview()

# ─────────────────────────────────────────────────────────────────────────────
# Drop
# ─────────────────────────────────────────────────────────────────────────────

## Drops the dragged stack onto an inventory slot.
func drop_on_inventory_slot(target_index: int) -> void:
	if not is_dragging or not _inventory_data:
		return

	drag_handled = true
	var target_stack := _inventory_data.get_slot(target_index)

	if target_stack == null or target_stack.is_empty():
		_inventory_data.set_slot(target_index, drag_stack)
	elif target_stack.item == drag_stack.item:
		var leftover := target_stack.merge_from(drag_stack)
		_inventory_data.slot_changed.emit(target_index)
		_inventory_data.inventory_changed.emit()
		if leftover and not leftover.is_empty():
			_return_leftover(leftover)
	else:
		_inventory_data.set_slot(target_index, drag_stack)
		_return_leftover(target_stack)

	_finish()


## Drops the dragged stack onto a hotbar slot.
func drop_on_hotbar_slot(hotbar_index: int) -> void:
	if not is_dragging or not _hotbar_data:
		return

	drag_handled = true
	var target_stack := _hotbar_data.get_slot(hotbar_index)

	if target_stack == null or target_stack.is_empty():
		_hotbar_data.set_slot(hotbar_index, drag_stack)
	elif target_stack.item == drag_stack.item:
		var leftover := target_stack.merge_from(drag_stack)
		_hotbar_data.slot_changed.emit(hotbar_index)
		_hotbar_data.inventory_changed.emit()
		if leftover and not leftover.is_empty():
			_return_leftover(leftover)
	else:
		_hotbar_data.set_slot(hotbar_index, drag_stack)
		_return_leftover(target_stack)

	_finish()


## Places exactly one item into an inventory slot (right-click while dragging).
func place_one_in_inventory(target_index: int) -> void:
	if not is_dragging or not _inventory_data or not drag_stack:
		return

	var target_stack := _inventory_data.get_slot(target_index)

	if target_stack == null or target_stack.is_empty():
		var one := ItemStack.create(drag_stack.item, 1)
		_inventory_data.set_slot(target_index, one)
		drag_stack.quantity -= 1
	elif target_stack.item == drag_stack.item and not target_stack.is_full():
		target_stack.add(1)
		_inventory_data.slot_changed.emit(target_index)
		_inventory_data.inventory_changed.emit()
		drag_stack.quantity -= 1
	else:
		return  # Can't place here

	if drag_stack.quantity <= 0:
		_finish()
	else:
		_update_quantity_label()


## Places exactly one item into a hotbar slot (right-click while dragging).
func place_one_in_hotbar(hotbar_index: int) -> void:
	if not is_dragging or not _hotbar_data or not drag_stack:
		return

	var target_stack := _hotbar_data.get_slot(hotbar_index)

	if target_stack == null or target_stack.is_empty():
		var one := ItemStack.create(drag_stack.item, 1)
		_hotbar_data.set_slot(hotbar_index, one)
		drag_stack.quantity -= 1
	elif target_stack.item == drag_stack.item and not target_stack.is_full():
		target_stack.add(1)
		_hotbar_data.slot_changed.emit(hotbar_index)
		_hotbar_data.inventory_changed.emit()
		drag_stack.quantity -= 1
	else:
		return  # Can't place here

	if drag_stack.quantity <= 0:
		_finish()
	else:
		_update_quantity_label()

# ─────────────────────────────────────────────────────────────────────────────
# End / Cancel
# ─────────────────────────────────────────────────────────────────────────────

## Called when the mouse is released outside any slot — return items to source.
func end_outside() -> void:
	if not is_dragging:
		return
	var source_data: InventoryData = _hotbar_data if drag_from_hotbar else _inventory_data
	if source_data:
		var source_stack := source_data.get_slot(drag_from_index)
		if source_stack and not source_stack.is_empty() and source_stack.item == drag_stack.item:
			var leftover := source_stack.merge_from(drag_stack)
			source_data.slot_changed.emit(drag_from_index)
			source_data.inventory_changed.emit()
			if leftover and not leftover.is_empty():
				var empty := source_data.find_empty_slot()
				if empty >= 0:
					source_data.set_slot(empty, leftover)
		else:
			source_data.set_slot(drag_from_index, drag_stack)
	_finish()


## Cancels the drag and returns items to their source slot.
func cancel() -> void:
	if not is_dragging:
		return
	var source_data: InventoryData = _hotbar_data if drag_from_hotbar else _inventory_data
	if source_data:
		source_data.set_slot(drag_from_index, drag_stack)
	_finish()

# ─────────────────────────────────────────────────────────────────────────────
# Preview
# ─────────────────────────────────────────────────────────────────────────────

## Updates the drag preview position to follow the cursor.
func update_preview_position() -> void:
	if not _drag_preview or not _drag_preview.visible:
		return
	var mouse_pos := _mouse_position_source.get_global_mouse_position()
	_drag_preview.position = mouse_pos - _drag_preview.size / 2.0

# ─────────────────────────────────────────────────────────────────────────────
# Private
# ─────────────────────────────────────────────────────────────────────────────

func _show_preview() -> void:
	if not _drag_preview:
		return
	if drag_stack and drag_stack.item and drag_stack.item.icon:
		_drag_preview.texture = drag_stack.item.icon
	else:
		var item_def: ItemDefinition = drag_stack.item if drag_stack else null
		_drag_preview.texture = PlaceholderTextureCache.get_for_item(item_def)

	# Show quantity on preview
	if _drag_quantity_label:
		if drag_stack and drag_stack.quantity > 1:
			_drag_quantity_label.text = str(drag_stack.quantity)
			_drag_quantity_label.visible = true
		else:
			_drag_quantity_label.visible = false

	_drag_preview.visible = true
	update_preview_position()


func _return_leftover(leftover: ItemStack) -> void:
	if drag_from_hotbar:
		_hotbar_data.set_slot(drag_from_index, leftover)
	else:
		_inventory_data.set_slot(drag_from_index, leftover)


func _update_quantity_label() -> void:
	if not _drag_quantity_label:
		return
	if drag_stack and drag_stack.quantity > 1:
		_drag_quantity_label.text = str(drag_stack.quantity)
		_drag_quantity_label.visible = true
	else:
		_drag_quantity_label.visible = false


func _finish() -> void:
	is_dragging = false
	drag_from_index = -1
	drag_from_hotbar = false
	drag_stack = null
	drag_handled = false
	drag_just_started = false
	if _drag_preview:
		_drag_preview.visible = false
	drag_ended.emit()
