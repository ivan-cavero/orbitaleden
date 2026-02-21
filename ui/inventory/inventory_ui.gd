class_name InventoryUI
extends CanvasLayer
## Full-screen inventory panel with a 6x5 grid of slots.
##
## Coordinates sub-components:
## - InventoryTooltip   — hover info for items
## - InventoryContextMenu — right-click actions (Use, Split, Discard)
## - InventorySplitMenu — shift+right-click stack splitting
## - InventoryDragHandler — drag-and-drop between slots/hotbar
##
## Features:
## - Toggle with Tab / Escape
## - Visual drag preview following the cursor (overlay layer 30)
## - Sort inventory button
## - Cross-UI drag between inventory and hotbar

# ─────────────────────────────────────────────────────────────────────────────
# Signals
# ─────────────────────────────────────────────────────────────────────────────

## Emitted when the inventory opens or closes.
signal inventory_toggled(is_open: bool)

## Emitted when an item is used/consumed from the inventory.
signal item_used(item: ItemDefinition, slot_index: int)

# ─────────────────────────────────────────────────────────────────────────────
# Constants
# ─────────────────────────────────────────────────────────────────────────────

const COLUMNS := 6
const ROWS := 5
const SLOT_COUNT := COLUMNS * ROWS  # 30
const SLOT_SIZE := 64
const SLOT_GAP := 4

# ─────────────────────────────────────────────────────────────────────────────
# State
# ─────────────────────────────────────────────────────────────────────────────

var _open := false
var _inventory_data: InventoryData = null

# ─────────────────────────────────────────────────────────────────────────────
# Node Refs (created in code)
# ─────────────────────────────────────────────────────────────────────────────

var _bg: ColorRect
var _panel: PanelContainer
var _title_label: Label
var _sort_button: Button
var _close_button: Button
var _grid: GridContainer
var _slots: Array[InventorySlot] = []
var _overlay_layer: CanvasLayer  # Layer above hotbar for drag preview, tooltips, popups
var _drag_preview: TextureRect
var _drag_quantity_label: Label

# Sub-components
var _tooltip: InventoryTooltip
var _context_menu: InventoryContextMenu
var _split_menu: InventorySplitMenu
var _drag_handler: InventoryDragHandler

# Hotbar integration
var _hotbar_ui: Node = null  # HotbarUI reference
var _hotbar_data: InventoryData = null

# ─────────────────────────────────────────────────────────────────────────────
# Lifecycle
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("inventory_ui")
	_build_ui()
	_setup_drag_handler()
	_hide_all()


func _input(event: InputEvent) -> void:
	if not _open:
		return

	# Close on Escape
	if event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and not key.echo:
			if key.physical_keycode == KEY_ESCAPE:
				if _context_menu.visible or _split_menu.visible:
					_context_menu.hide_menu()
					_split_menu.hide_menu()
					get_viewport().set_input_as_handled()
					return
				get_viewport().set_input_as_handled()
				close()
				return

	# Click outside menus to close them
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			if _context_menu.visible and not _is_mouse_over(_context_menu):
				_context_menu.hide_menu()
			if _split_menu.visible and not _is_mouse_over(_split_menu):
				_split_menu.hide_menu()

	# Drag preview follows cursor
	if _drag_handler.is_dragging and event is InputEventMouseMotion:
		_drag_handler.update_preview_position()

	# Release drag on mouse up anywhere (only if no slot already handled it)
	if _drag_handler.is_dragging and event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if not mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			if _drag_handler.drag_just_started:
				_drag_handler.drag_just_started = false
				return
			if _drag_handler.drag_handled:
				_drag_handler.drag_handled = false
			else:
				_drag_handler.end_outside()

# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

## Opens the inventory panel.
func open() -> void:
	if _open:
		return
	if is_instance_valid(Debug.console) and Debug.console.is_open():
		return

	_open = true
	_show_all()
	_refresh_all_slots()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if _hotbar_ui and _hotbar_ui.has_method("set_inventory_open"):
		_hotbar_ui.set_inventory_open(true)
	inventory_toggled.emit(true)
	Debug.info("Inventory opened")


## Closes the inventory panel.
func close() -> void:
	if not _open:
		return
	_drag_handler.cancel()
	_context_menu.hide_menu()
	_split_menu.hide_menu()
	_open = false
	_hide_all()
	_tooltip.hide_tooltip()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if _hotbar_ui and _hotbar_ui.has_method("set_inventory_open"):
		_hotbar_ui.set_inventory_open(false)
	inventory_toggled.emit(false)
	Debug.info("Inventory closed")


## Returns true if the inventory is currently open.
func is_open() -> bool:
	return _open


## Toggles the inventory open/closed.
func toggle() -> void:
	if _open:
		close()
	else:
		open()


## Connects this UI to an InventoryData resource.
func setup(inventory_data: InventoryData) -> void:
	_inventory_data = inventory_data
	_inventory_data.inventory_changed.connect(_on_inventory_changed)
	_inventory_data.slot_changed.connect(_on_slot_changed)
	if _open:
		_refresh_all_slots()


## Connects the hotbar for cross-UI drag-and-drop.
func setup_hotbar(hotbar_ui: Node, hotbar_data: InventoryData) -> void:
	_hotbar_ui = hotbar_ui
	_hotbar_data = hotbar_data
	_hotbar_ui.hotbar_slot_clicked.connect(_on_hotbar_slot_clicked)
	_hotbar_ui.hotbar_slot_shift_clicked.connect(_on_hotbar_slot_shift_clicked)
	_hotbar_ui.hotbar_slot_right_clicked.connect(_on_hotbar_slot_right_clicked)
	_hotbar_ui.hotbar_slot_hovered.connect(_on_hotbar_slot_hovered)

	# Update drag handler with hotbar data
	if _drag_handler:
		_drag_handler._hotbar_data = _hotbar_data

# ─────────────────────────────────────────────────────────────────────────────
# Build UI
# ─────────────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	_build_background()
	_build_main_panel()
	_build_overlay_layer()


func _build_background() -> void:
	_bg = ColorRect.new()
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg.color = Color(0, 0, 0, 0.5)
	_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_bg)


func _build_main_panel() -> void:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bg.add_child(center)

	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	center.add_child(_panel)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.08, 0.1, 0.95)
	panel_style.set_border_width_all(2)
	panel_style.border_color = Color(0.35, 0.35, 0.4, 0.9)
	panel_style.set_corner_radius_all(8)
	panel_style.set_content_margin_all(16)
	_panel.add_theme_stylebox_override("panel", panel_style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	_panel.add_child(vbox)

	_build_header(vbox)
	_build_separator(vbox)
	_build_grid(vbox)


func _build_header(parent: VBoxContainer) -> void:
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	parent.add_child(header)

	_title_label = Label.new()
	_title_label.text = "Inventory"
	_title_label.add_theme_font_size_override("font_size", 22)
	_title_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_title_label)

	_sort_button = _create_header_button("Sort", Vector2(60, 32),
		Color(0.2, 0.35, 0.5, 0.8), Color(0.3, 0.45, 0.6, 0.9))
	_sort_button.pressed.connect(_on_sort_pressed)
	header.add_child(_sort_button)

	_close_button = _create_header_button("X", Vector2(32, 32),
		Color(0.6, 0.2, 0.2, 0.8), Color(0.8, 0.3, 0.3, 0.9))
	_close_button.pressed.connect(close)
	header.add_child(_close_button)


func _build_separator(parent: VBoxContainer) -> void:
	var separator := HSeparator.new()
	separator.add_theme_constant_override("separation", 4)
	parent.add_child(separator)


func _build_grid(parent: VBoxContainer) -> void:
	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override("h_separation", SLOT_GAP)
	_grid.add_theme_constant_override("v_separation", SLOT_GAP)
	parent.add_child(_grid)

	for i in range(SLOT_COUNT):
		var slot := InventorySlot.new()
		slot.slot_index = i
		slot.slot_clicked.connect(_on_slot_clicked)
		slot.slot_shift_clicked.connect(_on_slot_shift_clicked)
		slot.slot_right_clicked.connect(_on_slot_right_clicked)
		slot.slot_shift_right_clicked.connect(_on_slot_shift_right_clicked)
		slot.slot_hovered.connect(_on_slot_hovered)
		_grid.add_child(slot)
		_slots.append(slot)


func _build_overlay_layer() -> void:
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 30
	_overlay_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_overlay_layer)

	# Tooltip
	_tooltip = InventoryTooltip.new()
	_overlay_layer.add_child(_tooltip)

	# Drag preview
	_drag_preview = TextureRect.new()
	_drag_preview.custom_minimum_size = Vector2(48, 48)
	_drag_preview.size = Vector2(48, 48)
	_drag_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_drag_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_preview.modulate.a = 0.7
	_drag_preview.visible = false
	_overlay_layer.add_child(_drag_preview)

	# Quantity label on drag preview
	_drag_quantity_label = Label.new()
	_drag_quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_drag_quantity_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_drag_quantity_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_drag_quantity_label.offset_right = -2
	_drag_quantity_label.offset_bottom = -1
	_drag_quantity_label.add_theme_font_size_override("font_size", 14)
	_drag_quantity_label.add_theme_color_override("font_color", Color.WHITE)
	_drag_quantity_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_drag_quantity_label.add_theme_constant_override("shadow_offset_x", 1)
	_drag_quantity_label.add_theme_constant_override("shadow_offset_y", 1)
	_drag_quantity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_quantity_label.visible = false
	_drag_preview.add_child(_drag_quantity_label)

	# Context menu
	_context_menu = InventoryContextMenu.new()
	_context_menu.use_requested.connect(_on_context_use)
	_context_menu.split_requested.connect(_on_context_split)
	_context_menu.discard_requested.connect(_on_context_discard)
	_overlay_layer.add_child(_context_menu)

	# Split menu
	_split_menu = InventorySplitMenu.new()
	_split_menu.split_confirmed.connect(_on_split_confirmed)
	_overlay_layer.add_child(_split_menu)


func _create_header_button(
	label_text: String, min_size: Vector2,
	normal_color: Color, hover_color: Color
) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = min_size
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = normal_color
	normal_style.set_corner_radius_all(4)
	normal_style.set_content_margin_all(4)
	button.add_theme_stylebox_override("normal", normal_style)
	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = hover_color
	hover_style.set_corner_radius_all(4)
	hover_style.set_content_margin_all(4)
	button.add_theme_stylebox_override("hover", hover_style)
	return button

# ─────────────────────────────────────────────────────────────────────────────
# Drag Handler Setup
# ─────────────────────────────────────────────────────────────────────────────

func _setup_drag_handler() -> void:
	_drag_handler = InventoryDragHandler.new()
	_drag_handler.drag_ended.connect(_on_drag_ended)


func _update_drag_handler_data() -> void:
	## Call after setup() and setup_hotbar() to give the drag handler current refs.
	_drag_handler.setup(_drag_preview, _drag_quantity_label, _inventory_data, _hotbar_data, _bg)

# ─────────────────────────────────────────────────────────────────────────────
# Visibility
# ─────────────────────────────────────────────────────────────────────────────

func _show_all() -> void:
	_bg.visible = true
	_overlay_layer.visible = true
	_update_drag_handler_data()


func _hide_all() -> void:
	_bg.visible = false
	_overlay_layer.visible = false

# ─────────────────────────────────────────────────────────────────────────────
# Slot Refresh
# ─────────────────────────────────────────────────────────────────────────────

func _refresh_all_slots() -> void:
	if not _inventory_data:
		return
	for i in range(SLOT_COUNT):
		_refresh_slot(i)

	for slot in _slots:
		slot.set_selected(false)


func _refresh_slot(index: int) -> void:
	if not _inventory_data or index < 0 or index >= _slots.size():
		return
	var stack := _inventory_data.get_slot(index)
	_slots[index].set_stack(stack)

# ─────────────────────────────────────────────────────────────────────────────
# Slot Click Handlers
# ─────────────────────────────────────────────────────────────────────────────

func _on_slot_clicked(slot_index: int) -> void:
	_context_menu.hide_menu()
	_split_menu.hide_menu()
	if _drag_handler.is_dragging:
		_drag_handler.drop_on_inventory_slot(slot_index)
	else:
		_drag_handler.start_from_inventory(slot_index)
		if _drag_handler.is_dragging:
			_slots[slot_index].set_selected(true)
			_tooltip.hide_tooltip()


func _on_slot_shift_clicked(slot_index: int) -> void:
	if _drag_handler.is_dragging:
		return
	_quick_move_to_hotbar(slot_index)


func _on_slot_right_clicked(slot_index: int) -> void:
	if _drag_handler.is_dragging:
		_drag_handler.place_one_in_inventory(slot_index)
		_refresh_all_slots()
	else:
		_split_menu.hide_menu()
		_tooltip.hide_tooltip()
		var stack := _inventory_data.get_slot(slot_index) if _inventory_data else null
		_context_menu.show_for_slot(
			slot_index, stack, _get_slot_global_rect(slot_index))


func _on_slot_shift_right_clicked(slot_index: int) -> void:
	if _drag_handler.is_dragging:
		_drag_handler.place_one_in_inventory(slot_index)
		_refresh_all_slots()
	else:
		_context_menu.hide_menu()
		_tooltip.hide_tooltip()
		var stack := _inventory_data.get_slot(slot_index) if _inventory_data else null
		_split_menu.show_for_slot(
			slot_index, stack, _get_slot_global_rect(slot_index))


func _on_slot_hovered(slot_index: int) -> void:
	if _drag_handler.is_dragging or _context_menu.visible or _split_menu.visible:
		return
	var item_def := _slots[slot_index].get_item_definition()
	if item_def:
		_tooltip.show_for_item(item_def)
	else:
		_tooltip.hide_tooltip()

# ─────────────────────────────────────────────────────────────────────────────
# Context Menu Callbacks
# ─────────────────────────────────────────────────────────────────────────────

func _on_context_use(slot_index: int) -> void:
	if not _inventory_data or slot_index < 0:
		return
	var stack := _inventory_data.get_slot(slot_index)
	if stack == null or stack.is_empty() or not stack.item.usable:
		return

	item_used.emit(stack.item, slot_index)

	stack.remove(1)
	if stack.is_empty():
		_inventory_data.clear_slot(slot_index)
	else:
		_inventory_data.slot_changed.emit(slot_index)
		_inventory_data.inventory_changed.emit()

	_refresh_all_slots()


func _on_context_split(slot_index: int) -> void:
	_tooltip.hide_tooltip()
	var stack := _inventory_data.get_slot(slot_index) if _inventory_data else null
	_split_menu.show_for_slot(
		slot_index, stack, _get_slot_global_rect(slot_index))


func _on_context_discard(slot_index: int) -> void:
	if not _inventory_data or slot_index < 0:
		return
	var stack := _inventory_data.get_slot(slot_index)
	if stack == null or stack.is_empty():
		return

	Debug.info("Discarded %dx %s" % [stack.quantity, stack.item.display_name])
	_inventory_data.clear_slot(slot_index)
	_refresh_all_slots()

# ─────────────────────────────────────────────────────────────────────────────
# Split Menu Callback
# ─────────────────────────────────────────────────────────────────────────────

func _on_split_confirmed(slot_index: int, amount: int) -> void:
	if not _inventory_data or slot_index < 0:
		return
	var stack := _inventory_data.get_slot(slot_index)
	if stack == null or stack.is_empty() or stack.quantity <= 1:
		return

	var clamped_amount := clampi(amount, 1, stack.quantity - 1)
	var split_stack := stack.split(clamped_amount)
	if split_stack == null:
		return

	_inventory_data.slot_changed.emit(slot_index)
	_inventory_data.inventory_changed.emit()

	_drag_handler.start_with_split_stack(slot_index, split_stack)
	_refresh_all_slots()

# ─────────────────────────────────────────────────────────────────────────────
# Hotbar Cross-Drag Integration
# ─────────────────────────────────────────────────────────────────────────────

func _on_hotbar_slot_clicked(hotbar_index: int) -> void:
	if not _open:
		return
	_context_menu.hide_menu()
	_split_menu.hide_menu()
	if _drag_handler.is_dragging:
		_drag_handler.drop_on_hotbar_slot(hotbar_index)
	else:
		_drag_handler.start_from_hotbar(hotbar_index)
		if _drag_handler.is_dragging:
			_tooltip.hide_tooltip()


func _on_hotbar_slot_shift_clicked(hotbar_index: int) -> void:
	if not _open or _drag_handler.is_dragging:
		return
	_quick_move_to_inventory(hotbar_index)


func _on_hotbar_slot_right_clicked(hotbar_index: int) -> void:
	if not _open:
		return
	if _drag_handler.is_dragging:
		_drag_handler.place_one_in_hotbar(hotbar_index)
		_refresh_all_slots()


func _on_hotbar_slot_hovered(hotbar_index: int) -> void:
	if not _open or _drag_handler.is_dragging:
		return
	if _context_menu.visible or _split_menu.visible:
		return
	if not _hotbar_data:
		_tooltip.hide_tooltip()
		return
	var stack := _hotbar_data.get_slot(hotbar_index)
	if stack and not stack.is_empty():
		_tooltip.show_for_item(stack.item)
	else:
		_tooltip.hide_tooltip()

# ─────────────────────────────────────────────────────────────────────────────
# Sort Inventory
# ─────────────────────────────────────────────────────────────────────────────

func _on_sort_pressed() -> void:
	if not _inventory_data or _drag_handler.is_dragging:
		return
	_sort_inventory()
	_refresh_all_slots()
	Debug.info("Inventory sorted")


func _sort_inventory() -> void:
	_merge_all_stacks()

	var stacks: Array[ItemStack] = []
	for i in range(SLOT_COUNT):
		var stack := _inventory_data.get_slot(i)
		if stack and not stack.is_empty():
			stacks.append(stack)

	stacks.sort_custom(_compare_stacks)

	for i in range(SLOT_COUNT):
		if i < stacks.size():
			_inventory_data.set_slot(i, stacks[i])
		else:
			var existing := _inventory_data.get_slot(i)
			if existing:
				_inventory_data.clear_slot(i)


func _merge_all_stacks() -> void:
	for i in range(SLOT_COUNT):
		var stack_i := _inventory_data.get_slot(i)
		if stack_i == null or stack_i.is_empty():
			continue
		for j in range(i + 1, SLOT_COUNT):
			var stack_j := _inventory_data.get_slot(j)
			if stack_j == null or stack_j.is_empty():
				continue
			if stack_j.item == stack_i.item and not stack_i.is_full():
				var leftover := stack_i.merge_from(stack_j)
				if leftover == null or leftover.is_empty():
					_inventory_data.clear_slot(j)
				if stack_i.is_full():
					break


func _compare_stacks(stack_a: ItemStack, stack_b: ItemStack) -> bool:
	if stack_a.item.category != stack_b.item.category:
		return stack_a.item.category < stack_b.item.category
	if stack_a.item.tier != stack_b.item.tier:
		return stack_a.item.tier < stack_b.item.tier
	if stack_a.item.display_name != stack_b.item.display_name:
		return stack_a.item.display_name < stack_b.item.display_name
	return stack_a.quantity > stack_b.quantity

# ─────────────────────────────────────────────────────────────────────────────
# Drag End Handler
# ─────────────────────────────────────────────────────────────────────────────

func _on_drag_ended() -> void:
	_refresh_all_slots()

# ─────────────────────────────────────────────────────────────────────────────
# Signal Handlers
# ─────────────────────────────────────────────────────────────────────────────

func _on_inventory_changed() -> void:
	if _open and not _drag_handler.is_dragging:
		_refresh_all_slots()


func _on_slot_changed(slot_index: int) -> void:
	if _open and not _drag_handler.is_dragging:
		_refresh_slot(slot_index)

# ─────────────────────────────────────────────────────────────────────────────
# Quick-Move (Shift+Click)
# ─────────────────────────────────────────────────────────────────────────────

## Moves an item from an inventory slot to the hotbar (first available slot).
func _quick_move_to_hotbar(inventory_slot_index: int) -> void:
	if not _inventory_data or not _hotbar_data:
		return
	var stack := _inventory_data.get_slot(inventory_slot_index)
	if stack == null or stack.is_empty():
		return

	var leftover := _hotbar_data.add_stack(stack)
	if leftover == null or leftover.is_empty():
		_inventory_data.clear_slot(inventory_slot_index)
	else:
		_inventory_data.set_slot(inventory_slot_index, leftover)
	_refresh_all_slots()


## Moves an item from a hotbar slot to the inventory (first available slot).
func _quick_move_to_inventory(hotbar_slot_index: int) -> void:
	if not _inventory_data or not _hotbar_data:
		return
	var stack := _hotbar_data.get_slot(hotbar_slot_index)
	if stack == null or stack.is_empty():
		return

	var leftover := _inventory_data.add_stack(stack)
	if leftover == null or leftover.is_empty():
		_hotbar_data.clear_slot(hotbar_slot_index)
	else:
		_hotbar_data.set_slot(hotbar_slot_index, leftover)
	_refresh_all_slots()

# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

func _is_mouse_over(control: Control) -> bool:
	if not control or not control.visible:
		return false
	var mouse := control.get_global_mouse_position()
	return control.get_global_rect().has_point(mouse)


func _get_slot_global_rect(slot_index: int) -> Rect2:
	if slot_index >= 0 and slot_index < _slots.size():
		return _slots[slot_index].get_global_rect()
	return Rect2()
