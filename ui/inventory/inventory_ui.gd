class_name InventoryUI
extends CanvasLayer
## Full-screen inventory panel with a 6x5 grid of slots.
##
## Features:
## - Toggle with Tab / Escape
## - Drag and drop items between slots
## - Cross-UI drag between inventory and hotbar
## - Right-click context menu (Use, Discard, etc.)
## - Shift+Right-click split menu with slider and presets
## - Tooltip on hover (inventory slots and hotbar slots)
## - Sort inventory button
## - Visual drag preview following the cursor (on overlay layer 30)

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

# Drag state
var _dragging := false
var _drag_from_index := -1
var _drag_from_hotbar := false  # True if drag originated from hotbar
var _drag_stack: ItemStack = null
var _drag_handled := false  # Set true when a slot handles the drop
var _drag_just_started := false  # Ignore the mouse-up from the click that started the drag

# Context / split menu state
var _context_slot_index := -1
var _split_slot_index := -1

# ─────────────────────────────────────────────────────────────────────────────
# Node refs (created in code)
# ─────────────────────────────────────────────────────────────────────────────

var _bg: ColorRect
var _panel: PanelContainer
var _title_label: Label
var _sort_button: Button
var _close_button: Button
var _grid: GridContainer
var _slots: Array[InventorySlot] = []
var _tooltip_panel: PanelContainer
var _tooltip_name: Label
var _tooltip_desc: Label
var _tooltip_info: Label
var _drag_preview: TextureRect
var _overlay_layer: CanvasLayer  # Layer above hotbar for drag preview, tooltips, popups

# Hotbar integration
var _hotbar_ui: Node = null  # HotbarUI reference
var _hotbar_data: InventoryData = null

# Context menu refs
var _context_menu: PanelContainer
var _context_vbox: VBoxContainer

# Split menu refs
var _split_menu: PanelContainer
var _split_slider: HSlider
var _split_input: SpinBox
var _split_label: Label
var _split_confirm_btn: Button

# ─────────────────────────────────────────────────────────────────────────────
# Lifecycle
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("inventory_ui")
	_build_ui()
	_hide_all()


func _input(event: InputEvent) -> void:
	if not _open:
		return

	# Close on Escape
	if event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and not key.echo:
			if key.physical_keycode == KEY_ESCAPE:
				# If a menu is open, close it first instead of closing inventory
				if _context_menu.visible or _split_menu.visible:
					_hide_context_menu()
					_hide_split_menu()
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
				_hide_context_menu()
			if _split_menu.visible and not _is_mouse_over(_split_menu):
				_hide_split_menu()

	# Drag preview follows cursor
	if _dragging and event is InputEventMouseMotion:
		_update_drag_preview_position()

	# Release drag on mouse up anywhere (only if no slot already handled it)
	if _dragging and event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if not mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			if _drag_just_started:
				# Ignore the mouse-up from the same click that started the drag
				_drag_just_started = false
				return
			if _drag_handled:
				_drag_handled = false
			else:
				_end_drag_outside()

# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

## Opens the inventory panel.
func open() -> void:
	if _open:
		return
	# Don't open if debug console is active
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
	_cancel_drag()
	_hide_context_menu()
	_hide_split_menu()
	_open = false
	_hide_all()
	_hide_tooltip()
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
	# Connect hotbar slot signals for cross-UI drag
	_hotbar_ui.hotbar_slot_clicked.connect(_on_hotbar_slot_clicked)
	_hotbar_ui.hotbar_slot_right_clicked.connect(_on_hotbar_slot_right_clicked)
	_hotbar_ui.hotbar_slot_hovered.connect(_on_hotbar_slot_hovered)

# ─────────────────────────────────────────────────────────────────────────────
# Build UI
# ─────────────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	_build_background()
	_build_main_panel()
	_build_overlay_layer()
	_build_tooltip()
	_build_drag_preview()
	_build_context_menu()
	_build_split_menu()


func _build_background() -> void:
	# Semi-transparent background overlay
	_bg = ColorRect.new()
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg.color = Color(0, 0, 0, 0.5)
	_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_bg)


func _build_main_panel() -> void:
	# Center container for the panel
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bg.add_child(center)

	# Main panel
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

	# Vertical layout
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	_panel.add_child(vbox)

	# Header row
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	vbox.add_child(header)

	_title_label = Label.new()
	_title_label.text = "Inventory"
	_title_label.add_theme_font_size_override("font_size", 22)
	_title_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_title_label)

	# Sort button
	_sort_button = Button.new()
	_sort_button.text = "Sort"
	_sort_button.custom_minimum_size = Vector2(60, 32)
	_sort_button.pressed.connect(_on_sort_pressed)
	var sort_style := StyleBoxFlat.new()
	sort_style.bg_color = Color(0.2, 0.35, 0.5, 0.8)
	sort_style.set_corner_radius_all(4)
	sort_style.set_content_margin_all(4)
	_sort_button.add_theme_stylebox_override("normal", sort_style)
	var sort_hover := StyleBoxFlat.new()
	sort_hover.bg_color = Color(0.3, 0.45, 0.6, 0.9)
	sort_hover.set_corner_radius_all(4)
	sort_hover.set_content_margin_all(4)
	_sort_button.add_theme_stylebox_override("hover", sort_hover)
	header.add_child(_sort_button)

	_close_button = Button.new()
	_close_button.text = "X"
	_close_button.custom_minimum_size = Vector2(32, 32)
	_close_button.pressed.connect(close)
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.6, 0.2, 0.2, 0.8)
	btn_style.set_corner_radius_all(4)
	btn_style.set_content_margin_all(4)
	_close_button.add_theme_stylebox_override("normal", btn_style)
	var btn_hover := StyleBoxFlat.new()
	btn_hover.bg_color = Color(0.8, 0.3, 0.3, 0.9)
	btn_hover.set_corner_radius_all(4)
	btn_hover.set_content_margin_all(4)
	_close_button.add_theme_stylebox_override("hover", btn_hover)
	header.add_child(_close_button)

	# Separator
	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 4)
	vbox.add_child(sep)

	# Grid of slots
	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override("h_separation", SLOT_GAP)
	_grid.add_theme_constant_override("v_separation", SLOT_GAP)
	vbox.add_child(_grid)

	# Create slots
	for i in range(SLOT_COUNT):
		var slot := InventorySlot.new()
		slot.slot_index = i
		slot.slot_clicked.connect(_on_slot_clicked)
		slot.slot_right_clicked.connect(_on_slot_right_clicked)
		slot.slot_shift_right_clicked.connect(_on_slot_shift_right_clicked)
		slot.slot_hovered.connect(_on_slot_hovered)
		_grid.add_child(slot)
		_slots.append(slot)


func _build_overlay_layer() -> void:
	# Separate CanvasLayer for drag preview, tooltips, and popup menus.
	# Sits above the hotbar (layer 25) so floating elements are never occluded.
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 30
	_overlay_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_overlay_layer)


func _build_tooltip() -> void:
	_tooltip_panel = PanelContainer.new()
	_tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip_panel.visible = false
	_overlay_layer.add_child(_tooltip_panel)

	var tip_style := StyleBoxFlat.new()
	tip_style.bg_color = Color(0.05, 0.05, 0.08, 0.95)
	tip_style.set_border_width_all(1)
	tip_style.border_color = Color(0.4, 0.4, 0.5, 0.8)
	tip_style.set_corner_radius_all(4)
	tip_style.set_content_margin_all(10)
	_tooltip_panel.add_theme_stylebox_override("panel", tip_style)

	var tip_vbox := VBoxContainer.new()
	tip_vbox.add_theme_constant_override("separation", 4)
	_tooltip_panel.add_child(tip_vbox)

	_tooltip_name = Label.new()
	_tooltip_name.add_theme_font_size_override("font_size", 16)
	_tooltip_name.add_theme_color_override("font_color", Color(1, 0.85, 0.4))
	tip_vbox.add_child(_tooltip_name)

	_tooltip_desc = Label.new()
	_tooltip_desc.add_theme_font_size_override("font_size", 13)
	_tooltip_desc.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	_tooltip_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tooltip_desc.custom_minimum_size.x = 200
	tip_vbox.add_child(_tooltip_desc)

	_tooltip_info = Label.new()
	_tooltip_info.add_theme_font_size_override("font_size", 12)
	_tooltip_info.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	tip_vbox.add_child(_tooltip_info)


func _build_drag_preview() -> void:
	_drag_preview = TextureRect.new()
	_drag_preview.custom_minimum_size = Vector2(48, 48)
	_drag_preview.size = Vector2(48, 48)
	_drag_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_drag_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_preview.modulate.a = 0.7
	_drag_preview.visible = false
	_overlay_layer.add_child(_drag_preview)


func _build_context_menu() -> void:
	_context_menu = PanelContainer.new()
	_context_menu.mouse_filter = Control.MOUSE_FILTER_STOP
	_context_menu.visible = false
	_overlay_layer.add_child(_context_menu)

	var ctx_style := StyleBoxFlat.new()
	ctx_style.bg_color = Color(0.1, 0.1, 0.13, 0.97)
	ctx_style.set_border_width_all(1)
	ctx_style.border_color = Color(0.4, 0.4, 0.5, 0.9)
	ctx_style.set_corner_radius_all(6)
	ctx_style.set_content_margin_all(6)
	_context_menu.add_theme_stylebox_override("panel", ctx_style)

	_context_vbox = VBoxContainer.new()
	_context_vbox.add_theme_constant_override("separation", 2)
	_context_menu.add_child(_context_vbox)


func _build_split_menu() -> void:
	_split_menu = PanelContainer.new()
	_split_menu.mouse_filter = Control.MOUSE_FILTER_STOP
	_split_menu.visible = false
	_overlay_layer.add_child(_split_menu)

	var split_style := StyleBoxFlat.new()
	split_style.bg_color = Color(0.1, 0.1, 0.13, 0.97)
	split_style.set_border_width_all(1)
	split_style.border_color = Color(0.35, 0.45, 0.6, 0.9)
	split_style.set_corner_radius_all(6)
	split_style.set_content_margin_all(12)
	_split_menu.add_theme_stylebox_override("panel", split_style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.custom_minimum_size.x = 220
	_split_menu.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "Split Stack"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Label showing "Take X / Y"
	_split_label = Label.new()
	_split_label.add_theme_font_size_override("font_size", 13)
	_split_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	_split_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_split_label)

	# Slider
	_split_slider = HSlider.new()
	_split_slider.min_value = 1
	_split_slider.max_value = 99
	_split_slider.step = 1
	_split_slider.custom_minimum_size.y = 20
	_split_slider.value_changed.connect(_on_split_slider_changed)
	vbox.add_child(_split_slider)

	# Input + preset buttons row
	var input_row := HBoxContainer.new()
	input_row.add_theme_constant_override("separation", 4)
	vbox.add_child(input_row)

	_split_input = SpinBox.new()
	_split_input.min_value = 1
	_split_input.max_value = 99
	_split_input.step = 1
	_split_input.custom_minimum_size.x = 70
	_split_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_split_input.value_changed.connect(_on_split_input_changed)
	input_row.add_child(_split_input)

	# Preset buttons row
	var presets_row := HBoxContainer.new()
	presets_row.add_theme_constant_override("separation", 4)
	vbox.add_child(presets_row)

	var preset_data := [["1", 0.0], ["1/4", 0.25], ["1/2", 0.5], ["3/4", 0.75], ["All", 1.0]]
	for pd in preset_data:
		var btn := Button.new()
		btn.text = pd[0]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 28)
		var ps := StyleBoxFlat.new()
		ps.bg_color = Color(0.18, 0.25, 0.35, 0.9)
		ps.set_corner_radius_all(3)
		ps.set_content_margin_all(2)
		btn.add_theme_stylebox_override("normal", ps)
		var ph := StyleBoxFlat.new()
		ph.bg_color = Color(0.25, 0.35, 0.5, 0.9)
		ph.set_corner_radius_all(3)
		ph.set_content_margin_all(2)
		btn.add_theme_stylebox_override("hover", ph)
		btn.add_theme_font_size_override("font_size", 12)
		var fraction: float = pd[1]
		btn.pressed.connect(_on_split_preset.bind(fraction))
		presets_row.add_child(btn)

	# Confirm button
	_split_confirm_btn = Button.new()
	_split_confirm_btn.text = "Split"
	_split_confirm_btn.custom_minimum_size = Vector2(0, 32)
	_split_confirm_btn.pressed.connect(_on_split_confirm)
	var confirm_style := StyleBoxFlat.new()
	confirm_style.bg_color = Color(0.2, 0.5, 0.3, 0.9)
	confirm_style.set_corner_radius_all(4)
	confirm_style.set_content_margin_all(4)
	_split_confirm_btn.add_theme_stylebox_override("normal", confirm_style)
	var confirm_hover := StyleBoxFlat.new()
	confirm_hover.bg_color = Color(0.3, 0.6, 0.4, 0.9)
	confirm_hover.set_corner_radius_all(4)
	confirm_hover.set_content_margin_all(4)
	_split_confirm_btn.add_theme_stylebox_override("hover", confirm_hover)
	vbox.add_child(_split_confirm_btn)

# ─────────────────────────────────────────────────────────────────────────────
# Visibility
# ─────────────────────────────────────────────────────────────────────────────

func _show_all() -> void:
	_bg.visible = true
	_overlay_layer.visible = true


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


func _refresh_slot(index: int) -> void:
	if not _inventory_data or index < 0 or index >= _slots.size():
		return
	var stack := _inventory_data.get_slot(index)
	_slots[index].set_stack(stack)

# ─────────────────────────────────────────────────────────────────────────────
# Slot Click Handlers
# ─────────────────────────────────────────────────────────────────────────────

func _on_slot_clicked(slot_index: int) -> void:
	_hide_context_menu()
	_hide_split_menu()
	if _dragging:
		_drop_on_slot(slot_index)
	else:
		_start_drag(slot_index)


func _on_slot_right_clicked(slot_index: int) -> void:
	if _dragging:
		# While dragging, right-click places one item
		_place_one_item(slot_index)
	else:
		_hide_split_menu()
		_show_context_menu(slot_index)


func _on_slot_shift_right_clicked(slot_index: int) -> void:
	if _dragging:
		# While dragging, Shift+right-click also places one item
		_place_one_item(slot_index)
	else:
		_hide_context_menu()
		_show_split_menu(slot_index)


func _on_slot_hovered(slot_index: int) -> void:
	if not _dragging and not _context_menu.visible and not _split_menu.visible:
		_show_tooltip(slot_index)

# ─────────────────────────────────────────────────────────────────────────────
# Context Menu
# ─────────────────────────────────────────────────────────────────────────────

func _show_context_menu(slot_index: int) -> void:
	if not _inventory_data:
		return

	var stack := _inventory_data.get_slot(slot_index)
	if stack == null or stack.is_empty():
		return

	_context_slot_index = slot_index
	_hide_tooltip()

	# Clear old buttons
	for child in _context_vbox.get_children():
		child.queue_free()

	var item_def := stack.item

	# Use action (label configured per-item in the resource)
	if item_def.usable:
		_add_context_button(item_def.get_use_label(), Color(0.3, 0.6, 0.35), _on_context_use)

	# Split action (available when stack has more than 1 item)
	if stack.quantity > 1:
		_add_context_button("Split", Color(0.3, 0.4, 0.6), _on_context_split)

	# Discard action (always available)
	_add_context_button("Discard", Color(0.6, 0.25, 0.25), _on_context_discard)

	# Position near the slot
	_context_menu.visible = true
	_context_menu.reset_size()
	_position_popup_near_slot(slot_index, _context_menu)


func _add_context_button(text: String, color: Color, callback: Callable) -> void:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(120, 30)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

	var style := StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, 0.15)
	style.set_corner_radius_all(3)
	style.set_content_margin_all(6)
	btn.add_theme_stylebox_override("normal", style)

	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = Color(color.r, color.g, color.b, 0.4)
	hover_style.set_corner_radius_all(3)
	hover_style.set_content_margin_all(6)
	btn.add_theme_stylebox_override("hover", hover_style)

	btn.add_theme_font_size_override("font_size", 14)
	btn.pressed.connect(callback)
	_context_vbox.add_child(btn)


func _hide_context_menu() -> void:
	if _context_menu:
		_context_menu.visible = false
	_context_slot_index = -1


func _on_context_use() -> void:
	if not _inventory_data or _context_slot_index < 0:
		_hide_context_menu()
		return

	var stack := _inventory_data.get_slot(_context_slot_index)
	if stack == null or stack.is_empty() or not stack.item.usable:
		_hide_context_menu()
		return

	var item_def := stack.item
	item_used.emit(item_def, _context_slot_index)

	# Consume one from the stack
	stack.remove(1)
	if stack.is_empty():
		_inventory_data.clear_slot(_context_slot_index)
	else:
		_inventory_data.slot_changed.emit(_context_slot_index)
		_inventory_data.inventory_changed.emit()

	Debug.info("Used %s" % item_def.display_name)
	_hide_context_menu()
	_refresh_all_slots()


func _on_context_discard() -> void:
	if not _inventory_data or _context_slot_index < 0:
		_hide_context_menu()
		return

	var stack := _inventory_data.get_slot(_context_slot_index)
	if stack == null or stack.is_empty():
		_hide_context_menu()
		return

	var item_name := stack.item.display_name
	var qty := stack.quantity
	_inventory_data.clear_slot(_context_slot_index)
	Debug.info("Discarded %dx %s" % [qty, item_name])
	_hide_context_menu()
	_refresh_all_slots()


func _on_context_split() -> void:
	var slot_index := _context_slot_index
	_hide_context_menu()
	_show_split_menu(slot_index)


# ─────────────────────────────────────────────────────────────────────────────
# Split Menu
# ─────────────────────────────────────────────────────────────────────────────

func _show_split_menu(slot_index: int) -> void:
	if not _inventory_data:
		return

	var stack := _inventory_data.get_slot(slot_index)
	if stack == null or stack.is_empty() or stack.quantity <= 1:
		return

	_split_slot_index = slot_index
	_hide_tooltip()

	# Configure slider/input range
	var max_split := stack.quantity - 1  # Must leave at least 1
	_split_slider.min_value = 1
	_split_slider.max_value = max_split
	_split_slider.value = ceili(max_split / 2.0)
	_split_input.min_value = 1
	_split_input.max_value = max_split
	_split_input.value = _split_slider.value
	_update_split_label(stack)

	# Show and position
	_split_menu.visible = true
	_split_menu.reset_size()
	_position_popup_near_slot(slot_index, _split_menu)


func _hide_split_menu() -> void:
	if _split_menu:
		_split_menu.visible = false
	_split_slot_index = -1


func _update_split_label(stack: ItemStack) -> void:
	if not stack:
		return
	var take := int(_split_slider.value)
	_split_label.text = "Take %d / %d" % [take, stack.quantity]


func _on_split_slider_changed(value: float) -> void:
	_split_input.value = value
	if _split_slot_index >= 0 and _inventory_data:
		var stack := _inventory_data.get_slot(_split_slot_index)
		_update_split_label(stack)


func _on_split_input_changed(value: float) -> void:
	_split_slider.value = value
	if _split_slot_index >= 0 and _inventory_data:
		var stack := _inventory_data.get_slot(_split_slot_index)
		_update_split_label(stack)


func _on_split_preset(fraction: float) -> void:
	if _split_slot_index < 0 or not _inventory_data:
		return
	var stack := _inventory_data.get_slot(_split_slot_index)
	if not stack:
		return

	var max_split := stack.quantity - 1
	var amount: int
	if fraction <= 0.0:
		amount = 1
	elif fraction >= 1.0:
		amount = max_split
	else:
		amount = clampi(int(stack.quantity * fraction), 1, max_split)

	_split_slider.value = amount
	_split_input.value = amount
	_update_split_label(stack)


func _on_split_confirm() -> void:
	if _split_slot_index < 0 or not _inventory_data:
		_hide_split_menu()
		return

	var stack := _inventory_data.get_slot(_split_slot_index)
	if stack == null or stack.is_empty() or stack.quantity <= 1:
		_hide_split_menu()
		return

	var split_amount := clampi(int(_split_slider.value), 1, stack.quantity - 1)
	var split := stack.split(split_amount)

	if split == null:
		_hide_split_menu()
		return

	_inventory_data.slot_changed.emit(_split_slot_index)
	_inventory_data.inventory_changed.emit()

	# Start dragging the split portion
	_dragging = true
	_drag_from_index = _split_slot_index
	_drag_stack = split
	_drag_just_started = true

	if _drag_stack.item and _drag_stack.item.icon:
		_drag_preview.texture = _drag_stack.item.icon
	else:
		_drag_preview.texture = _create_drag_placeholder()
	_drag_preview.visible = true
	_update_drag_preview_position()

	_hide_split_menu()
	_refresh_all_slots()

# ─────────────────────────────────────────────────────────────────────────────
# Popup Positioning Helpers
# ─────────────────────────────────────────────────────────────────────────────

func _position_popup_near_slot(slot_index: int, popup: PanelContainer) -> void:
	if slot_index < 0 or slot_index >= _slots.size():
		return

	var slot := _slots[slot_index]
	var slot_rect := slot.get_global_rect()
	var popup_pos := Vector2(slot_rect.position.x + slot_rect.size.x + 4, slot_rect.position.y)

	# Keep on screen
	var viewport_size := get_viewport().get_visible_rect().size
	var popup_size := popup.size

	if popup_pos.x + popup_size.x > viewport_size.x:
		popup_pos.x = slot_rect.position.x - popup_size.x - 4
	if popup_pos.y + popup_size.y > viewport_size.y:
		popup_pos.y = viewport_size.y - popup_size.y - 8

	popup.position = popup_pos


func _is_mouse_over(ctrl: Control) -> bool:
	if not ctrl or not ctrl.visible:
		return false
	var mouse := ctrl.get_global_mouse_position()
	return ctrl.get_global_rect().has_point(mouse)

# ─────────────────────────────────────────────────────────────────────────────
# Drag and Drop
# ─────────────────────────────────────────────────────────────────────────────

func _start_drag(slot_index: int) -> void:
	if not _inventory_data:
		return

	var stack := _inventory_data.get_slot(slot_index)
	if stack == null or stack.is_empty():
		return

	_dragging = true
	_drag_from_index = slot_index
	_drag_from_hotbar = false
	_drag_stack = stack.duplicate_stack()
	_drag_just_started = true

	# Remove from inventory visually
	_inventory_data.clear_slot(slot_index)

	# Show drag preview
	if _drag_stack.item and _drag_stack.item.icon:
		_drag_preview.texture = _drag_stack.item.icon
	else:
		_drag_preview.texture = _create_drag_placeholder()
	_drag_preview.visible = true
	_update_drag_preview_position()

	# Dim the source slot
	_slots[slot_index].set_selected(true)
	_hide_tooltip()


func _drop_on_slot(target_index: int) -> void:
	if not _dragging or not _inventory_data:
		return

	_drag_handled = true  # Prevent _input() from also calling _end_drag_outside()

	var target_stack := _inventory_data.get_slot(target_index)

	if target_stack == null or target_stack.is_empty():
		# Empty slot: place the dragged stack
		_inventory_data.set_slot(target_index, _drag_stack)
	elif target_stack.item == _drag_stack.item:
		# Same item: try to merge (works for rejoining split stacks)
		var leftover := target_stack.merge_from(_drag_stack)
		_inventory_data.slot_changed.emit(target_index)
		_inventory_data.inventory_changed.emit()
		if leftover and not leftover.is_empty():
			# Put leftover back in source
			_return_drag_leftover(leftover)
	else:
		# Different item: swap
		_inventory_data.set_slot(target_index, _drag_stack)
		_return_drag_leftover(target_stack)

	_finish_drag()


func _end_drag_outside() -> void:
	# Dropped outside any slot — return to original position
	if _dragging:
		var source_data: InventoryData = _hotbar_data if _drag_from_hotbar else _inventory_data
		if source_data:
			var source_stack := source_data.get_slot(_drag_from_index)
			if source_stack and not source_stack.is_empty() and source_stack.item == _drag_stack.item:
				var leftover := source_stack.merge_from(_drag_stack)
				source_data.slot_changed.emit(_drag_from_index)
				source_data.inventory_changed.emit()
				if leftover and not leftover.is_empty():
					var empty := source_data.find_empty_slot()
					if empty >= 0:
						source_data.set_slot(empty, leftover)
			else:
				source_data.set_slot(_drag_from_index, _drag_stack)
	_finish_drag()


func _cancel_drag() -> void:
	if _dragging:
		var source_data: InventoryData = _hotbar_data if _drag_from_hotbar else _inventory_data
		if source_data:
			source_data.set_slot(_drag_from_index, _drag_stack)
	_finish_drag()


func _finish_drag() -> void:
	_dragging = false
	_drag_from_index = -1
	_drag_from_hotbar = false
	_drag_stack = null
	_drag_handled = false
	_drag_just_started = false
	_drag_preview.visible = false

	for slot in _slots:
		slot.set_selected(false)

	_refresh_all_slots()


func _place_one_item(target_index: int) -> void:
	# While dragging, right-click places exactly 1 item in the target slot.
	if not _dragging or not _inventory_data or not _drag_stack:
		return

	var target_stack := _inventory_data.get_slot(target_index)

	if target_stack == null or target_stack.is_empty():
		# Place 1 item in empty slot
		var one := ItemStack.create(_drag_stack.item, 1)
		_inventory_data.set_slot(target_index, one)
		_drag_stack.quantity -= 1
	elif target_stack.item == _drag_stack.item and not target_stack.is_full():
		# Add 1 to existing stack of same type
		target_stack.add(1)
		_inventory_data.slot_changed.emit(target_index)
		_inventory_data.inventory_changed.emit()
		_drag_stack.quantity -= 1
	else:
		return  # Can't place here

	# If we ran out of items, end drag
	if _drag_stack.quantity <= 0:
		_finish_drag()
	else:
		_refresh_all_slots()

# ─────────────────────────────────────────────────────────────────────────────
# Sort Inventory
# ─────────────────────────────────────────────────────────────────────────────

func _on_sort_pressed() -> void:
	if not _inventory_data or _dragging:
		return
	_sort_inventory()
	_refresh_all_slots()
	Debug.info("Inventory sorted")


func _sort_inventory() -> void:
	# Step 1: Merge stacks of the same item type
	_merge_all_stacks()

	# Step 2: Collect non-empty stacks
	var stacks: Array[ItemStack] = []
	for i in range(SLOT_COUNT):
		var stack := _inventory_data.get_slot(i)
		if stack and not stack.is_empty():
			stacks.append(stack)

	# Step 3: Sort by category, then tier, then display_name, then quantity desc
	stacks.sort_custom(_compare_stacks)

	# Step 4: Reassign to slots
	for i in range(SLOT_COUNT):
		if i < stacks.size():
			_inventory_data.set_slot(i, stacks[i])
		else:
			# Clear remaining slots without triggering signal spam
			var existing := _inventory_data.get_slot(i)
			if existing:
				_inventory_data.clear_slot(i)


func _merge_all_stacks() -> void:
	# For each item type, merge partial stacks together
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
				# If stack_i is now full, break to move to next i
				if stack_i.is_full():
					break


func _compare_stacks(a: ItemStack, b: ItemStack) -> bool:
	# Sort by: category asc, tier asc, display_name asc, quantity desc
	if a.item.category != b.item.category:
		return a.item.category < b.item.category
	if a.item.tier != b.item.tier:
		return a.item.tier < b.item.tier
	if a.item.display_name != b.item.display_name:
		return a.item.display_name < b.item.display_name
	return a.quantity > b.quantity

# ─────────────────────────────────────────────────────────────────────────────
# Tooltip
# ─────────────────────────────────────────────────────────────────────────────

func _show_tooltip(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= _slots.size():
		_hide_tooltip()
		return

	var item_def := _slots[slot_index].get_item_definition()
	if item_def == null:
		_hide_tooltip()
		return

	_tooltip_name.text = item_def.display_name

	if item_def.description.is_empty():
		_tooltip_desc.visible = false
	else:
		_tooltip_desc.text = item_def.description
		_tooltip_desc.visible = true

	# Info line: category, tier, stack info
	var info_parts: Array[String] = []
	info_parts.append(ItemDefinition.get_category_name(item_def.category))
	info_parts.append("Tier %d" % item_def.tier)
	info_parts.append("Stack: %d" % item_def.stack_size)
	_tooltip_info.text = " | ".join(info_parts)

	_tooltip_panel.visible = true
	_update_tooltip_position()


func _hide_tooltip() -> void:
	if _tooltip_panel:
		_tooltip_panel.visible = false


func _update_tooltip_position() -> void:
	if not _tooltip_panel or not _tooltip_panel.visible:
		return

	# Force layout so we can read the tooltip's actual size immediately.
	_tooltip_panel.reset_size()

	var mouse_pos := _bg.get_global_mouse_position()
	var tip_offset := Vector2(16, 16)
	var tip_pos := mouse_pos + tip_offset

	# Keep tooltip on screen
	var viewport_size := get_viewport().get_visible_rect().size
	var tip_size := _tooltip_panel.size

	if tip_pos.x + tip_size.x > viewport_size.x:
		tip_pos.x = mouse_pos.x - tip_size.x - 8
	if tip_pos.y + tip_size.y > viewport_size.y:
		tip_pos.y = mouse_pos.y - tip_size.y - 8

	_tooltip_panel.position = tip_pos

# ─────────────────────────────────────────────────────────────────────────────
# Drag Preview Position
# ─────────────────────────────────────────────────────────────────────────────

func _update_drag_preview_position() -> void:
	if not _drag_preview.visible:
		return
	var mouse_pos := _bg.get_global_mouse_position()
	_drag_preview.position = mouse_pos - _drag_preview.size / 2.0


func _create_drag_placeholder() -> Texture2D:
	var img := Image.create(48, 48, false, Image.FORMAT_RGBA8)
	var color := Color(0.5, 0.5, 0.5, 0.6)
	if _drag_stack and _drag_stack.item:
		color = _drag_stack.item.color
		color.a = 0.6
	img.fill(color)
	return ImageTexture.create_from_image(img)

# ─────────────────────────────────────────────────────────────────────────────
# Hotbar Cross-Drag Integration
# ─────────────────────────────────────────────────────────────────────────────

func _on_hotbar_slot_clicked(hotbar_index: int) -> void:
	if not _open:
		return
	_hide_context_menu()
	_hide_split_menu()
	if _dragging:
		_drop_on_hotbar_slot(hotbar_index)
	else:
		_start_drag_from_hotbar(hotbar_index)


func _on_hotbar_slot_right_clicked(hotbar_index: int) -> void:
	if not _open:
		return
	if _dragging:
		_place_one_item_hotbar(hotbar_index)


func _on_hotbar_slot_hovered(hotbar_index: int) -> void:
	if not _open or _dragging or _context_menu.visible or _split_menu.visible:
		return
	_show_tooltip_for_hotbar(hotbar_index)


func _start_drag_from_hotbar(hotbar_index: int) -> void:
	if not _hotbar_data:
		return

	var stack := _hotbar_data.get_slot(hotbar_index)
	if stack == null or stack.is_empty():
		return

	_dragging = true
	_drag_from_index = hotbar_index
	_drag_from_hotbar = true
	_drag_stack = stack.duplicate_stack()
	_drag_just_started = true

	# Remove from hotbar visually
	_hotbar_data.clear_slot(hotbar_index)

	# Show drag preview
	if _drag_stack.item and _drag_stack.item.icon:
		_drag_preview.texture = _drag_stack.item.icon
	else:
		_drag_preview.texture = _create_drag_placeholder()
	_drag_preview.visible = true
	_update_drag_preview_position()
	_hide_tooltip()


func _drop_on_hotbar_slot(hotbar_index: int) -> void:
	if not _dragging or not _hotbar_data:
		return

	_drag_handled = true

	var target_stack := _hotbar_data.get_slot(hotbar_index)

	if target_stack == null or target_stack.is_empty():
		# Empty slot: place the dragged stack
		_hotbar_data.set_slot(hotbar_index, _drag_stack)
	elif target_stack.item == _drag_stack.item:
		# Same item: try to merge
		var leftover := target_stack.merge_from(_drag_stack)
		_hotbar_data.slot_changed.emit(hotbar_index)
		_hotbar_data.inventory_changed.emit()
		if leftover and not leftover.is_empty():
			# Put leftover back in source
			_return_drag_leftover(leftover)
	else:
		# Different item: swap
		_hotbar_data.set_slot(hotbar_index, _drag_stack)
		# Put old target item back in source
		_return_drag_leftover(target_stack)

	_finish_drag()


func _place_one_item_hotbar(hotbar_index: int) -> void:
	## While dragging, right-click places exactly 1 item in a hotbar slot.
	if not _dragging or not _hotbar_data or not _drag_stack:
		return

	var target_stack := _hotbar_data.get_slot(hotbar_index)

	if target_stack == null or target_stack.is_empty():
		var one := ItemStack.create(_drag_stack.item, 1)
		_hotbar_data.set_slot(hotbar_index, one)
		_drag_stack.quantity -= 1
	elif target_stack.item == _drag_stack.item and not target_stack.is_full():
		target_stack.add(1)
		_hotbar_data.slot_changed.emit(hotbar_index)
		_hotbar_data.inventory_changed.emit()
		_drag_stack.quantity -= 1
	else:
		return  # Can't place here

	if _drag_stack.quantity <= 0:
		_finish_drag()
	else:
		_refresh_all_slots()


func _return_drag_leftover(leftover: ItemStack) -> void:
	## Puts a leftover stack back into the source (inventory or hotbar).
	if _drag_from_hotbar:
		_hotbar_data.set_slot(_drag_from_index, leftover)
	else:
		_inventory_data.set_slot(_drag_from_index, leftover)


func _show_tooltip_for_hotbar(hotbar_index: int) -> void:
	if not _hotbar_data:
		_hide_tooltip()
		return

	var stack := _hotbar_data.get_slot(hotbar_index)
	if stack == null or stack.is_empty():
		_hide_tooltip()
		return

	var item_def := stack.item
	_tooltip_name.text = item_def.display_name

	if item_def.description.is_empty():
		_tooltip_desc.visible = false
	else:
		_tooltip_desc.text = item_def.description
		_tooltip_desc.visible = true

	var info_parts: Array[String] = []
	info_parts.append(ItemDefinition.get_category_name(item_def.category))
	info_parts.append("Tier %d" % item_def.tier)
	info_parts.append("Stack: %d" % item_def.stack_size)
	_tooltip_info.text = " | ".join(info_parts)

	_tooltip_panel.visible = true
	_update_tooltip_position()

# ─────────────────────────────────────────────────────────────────────────────
# Signal Handlers
# ─────────────────────────────────────────────────────────────────────────────

func _on_inventory_changed() -> void:
	if _open and not _dragging:
		_refresh_all_slots()


func _on_slot_changed(slot_index: int) -> void:
	if _open and not _dragging:
		_refresh_slot(slot_index)
