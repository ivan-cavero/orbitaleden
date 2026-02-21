class_name HotbarUI
extends CanvasLayer
## Always-visible hotbar with 8 item slots at the bottom center of the screen.
##
## Features:
## - Number keys 1-8 to select a slot
## - Mouse scroll wheel to cycle slots
## - Selected slot highlighted with border
## - F key or right-click to use the selected slot's item
## - Drag items from inventory to hotbar (when inventory is open)
## - Drag items between hotbar slots
## - Tooltip on hover (when inventory is open)
## - Automatically raises above inventory overlay when inventory is open

# ─────────────────────────────────────────────────────────────────────────────
# Signals
# ─────────────────────────────────────────────────────────────────────────────

## Emitted when an item is used from the hotbar.
signal item_used(item: ItemDefinition, slot_index: int)

## Emitted when the selected slot changes.
signal selection_changed(slot_index: int)

## Emitted when a hotbar slot is clicked (for cross-UI drag integration).
signal hotbar_slot_clicked(slot_index: int)

## Emitted when a hotbar slot is shift+clicked (quick-move to inventory).
signal hotbar_slot_shift_clicked(slot_index: int)

## Emitted when a hotbar slot is right-clicked.
signal hotbar_slot_right_clicked(slot_index: int)

## Emitted when a hotbar slot is hovered.
signal hotbar_slot_hovered(slot_index: int)

# ─────────────────────────────────────────────────────────────────────────────
# Constants
# ─────────────────────────────────────────────────────────────────────────────

const SLOT_COUNT := 8
const SLOT_SIZE := 64
const SLOT_GAP := 4
const BOTTOM_MARGIN := 20

# Colors
const BG_COLOR := Color(0.06, 0.06, 0.08, 0.85)
const BORDER_COLOR := Color(0.3, 0.3, 0.35, 0.8)
const SELECTED_BORDER_COLOR := Color(0.9, 0.75, 0.3, 0.95)
const SLOT_BG_COLOR := Color(0.12, 0.12, 0.15, 0.9)
const SLOT_BORDER_COLOR := Color(0.3, 0.3, 0.35, 0.8)
const KEY_LABEL_COLOR := Color(0.55, 0.55, 0.6, 0.8)
const KEY_LABEL_SELECTED_COLOR := Color(0.9, 0.75, 0.3, 0.95)
const HOVER_TINT := Color(1, 1, 1, 0.1)

# ─────────────────────────────────────────────────────────────────────────────
# State
# ─────────────────────────────────────────────────────────────────────────────

var _selected_index: int = 0
var _hotbar_data: InventoryData = null
var _inventory_open: bool = false

# ─────────────────────────────────────────────────────────────────────────────
# Node Refs (created in code)
# ─────────────────────────────────────────────────────────────────────────────

var _root_control: Control
var _panel: PanelContainer
var _hbox: HBoxContainer
var _slot_panels: Array[PanelContainer] = []
var _slot_icons: Array[TextureRect] = []
var _slot_quantities: Array[Label] = []
var _slot_key_labels: Array[Label] = []
var _slot_highlights: Array[ColorRect] = []

# ─────────────────────────────────────────────────────────────────────────────
# Lifecycle
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_refresh_all_slots()
	_update_selection_visuals()


func _input(event: InputEvent) -> void:
	# Don't process hotbar keys when console is open
	if is_instance_valid(Debug.console) and Debug.console.is_open():
		return

	# Number keys 1-8 to select slot
	for i in range(SLOT_COUNT):
		var action := "hotbar_%d" % (i + 1)
		if event.is_action_pressed(action):
			select_slot(i)
			get_viewport().set_input_as_handled()
			return

	# Mouse scroll wheel to cycle slots (only when inventory is NOT open)
	if not _inventory_open and event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed:
			if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
				select_slot((_selected_index - 1 + SLOT_COUNT) % SLOT_COUNT)
				get_viewport().set_input_as_handled()
				return
			elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				select_slot((_selected_index + 1) % SLOT_COUNT)
				get_viewport().set_input_as_handled()
				return

	# F key to use selected item (only when inventory is NOT open)
	if not _inventory_open and event.is_action_pressed("hotbar_use"):
		use_selected_item()
		get_viewport().set_input_as_handled()
		return

# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

## Connects this hotbar to a HotbarData (InventoryData with 8 slots).
func setup(hotbar_data: InventoryData) -> void:
	_hotbar_data = hotbar_data
	_hotbar_data.inventory_changed.connect(_on_hotbar_changed)
	_hotbar_data.slot_changed.connect(_on_slot_changed)
	_refresh_all_slots()


## Selects a hotbar slot by index.
func select_slot(index: int) -> void:
	if index < 0 or index >= SLOT_COUNT:
		return
	_selected_index = index
	_update_selection_visuals()
	selection_changed.emit(index)


## Returns the currently selected slot index.
func get_selected_index() -> int:
	return _selected_index


## Returns the item in the currently selected slot (or null).
func get_selected_item() -> ItemDefinition:
	if not _hotbar_data:
		return null
	var stack := _hotbar_data.get_slot(_selected_index)
	if stack and not stack.is_empty():
		return stack.item
	return null


## Returns the stack in the currently selected slot (or null).
func get_selected_stack() -> ItemStack:
	if not _hotbar_data:
		return null
	return _hotbar_data.get_slot(_selected_index)


## Uses the item in the currently selected slot.
func use_selected_item() -> void:
	if not _hotbar_data:
		return

	var stack := _hotbar_data.get_slot(_selected_index)
	if stack == null or stack.is_empty() or not stack.item.usable:
		return

	var item_def := stack.item
	item_used.emit(item_def, _selected_index)

	# Consume one from the stack
	stack.remove(1)
	if stack.is_empty():
		_hotbar_data.clear_slot(_selected_index)
	else:
		_hotbar_data.slot_changed.emit(_selected_index)
		_hotbar_data.inventory_changed.emit()



## Notifies the hotbar whether the inventory UI is open.
## Raises the hotbar layer above the inventory overlay so it stays visible.
func set_inventory_open(is_open: bool) -> void:
	_inventory_open = is_open
	# Inventory is on layer 20; raise hotbar above it when open, restore when closed
	layer = 25 if is_open else 10

# ─────────────────────────────────────────────────────────────────────────────
# Build UI
# ─────────────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	# Root control anchored to bottom center
	_root_control = Control.new()
	_root_control.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root_control)

	# Calculate total width
	var total_width := SLOT_COUNT * SLOT_SIZE + (SLOT_COUNT - 1) * SLOT_GAP + 16  # +16 for panel padding

	# Main panel container
	_panel = PanelContainer.new()
	_panel.position = Vector2(-total_width / 2.0, -SLOT_SIZE - BOTTOM_MARGIN - 32)  # 32 for label + padding
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = BG_COLOR
	panel_style.set_border_width_all(1)
	panel_style.border_color = BORDER_COLOR
	panel_style.set_corner_radius_all(6)
	panel_style.content_margin_left = 8
	panel_style.content_margin_right = 8
	panel_style.content_margin_top = 4
	panel_style.content_margin_bottom = 8
	_panel.add_theme_stylebox_override("panel", panel_style)
	_root_control.add_child(_panel)

	# Vertical box: key labels row + slots row
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(vbox)

	# Key labels row
	var key_row := HBoxContainer.new()
	key_row.add_theme_constant_override("separation", SLOT_GAP)
	key_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(key_row)

	# Slots row
	_hbox = HBoxContainer.new()
	_hbox.add_theme_constant_override("separation", SLOT_GAP)
	_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_hbox)

	# Create slots
	for i in range(SLOT_COUNT):
		_build_key_label(key_row, i)
		_build_slot(i)


func _build_key_label(parent: HBoxContainer, index: int) -> void:
	var label := Label.new()
	label.text = str(index + 1)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(SLOT_SIZE, 14)
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", KEY_LABEL_COLOR)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	_slot_key_labels.append(label)


func _build_slot(index: int) -> void:
	# Outer panel acts as the selection border
	var outer := PanelContainer.new()
	outer.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
	outer.mouse_filter = Control.MOUSE_FILTER_STOP

	var outer_style := StyleBoxFlat.new()
	outer_style.bg_color = SLOT_BG_COLOR
	outer_style.set_border_width_all(2)
	outer_style.border_color = SLOT_BORDER_COLOR
	outer_style.set_corner_radius_all(4)
	outer_style.set_content_margin_all(2)
	outer.add_theme_stylebox_override("panel", outer_style)

	# Connect input
	outer.gui_input.connect(_on_slot_gui_input.bind(index))
	outer.mouse_entered.connect(_on_slot_mouse_entered.bind(index))
	outer.mouse_exited.connect(_on_slot_mouse_exited.bind(index))

	_hbox.add_child(outer)
	_slot_panels.append(outer)

	# Icon
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(48, 48)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer.add_child(icon)
	_slot_icons.append(icon)

	# Quantity label
	var qty_label := Label.new()
	qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	qty_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	qty_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	qty_label.offset_right = -4
	qty_label.offset_bottom = -2
	qty_label.add_theme_font_size_override("font_size", 14)
	qty_label.add_theme_color_override("font_color", Color.WHITE)
	qty_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	qty_label.add_theme_constant_override("shadow_offset_x", 1)
	qty_label.add_theme_constant_override("shadow_offset_y", 1)
	qty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	qty_label.visible = false
	outer.add_child(qty_label)
	_slot_quantities.append(qty_label)

	# Hover highlight
	var highlight := ColorRect.new()
	highlight.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	highlight.color = Color(1, 1, 1, 0)
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer.add_child(highlight)
	_slot_highlights.append(highlight)

# ─────────────────────────────────────────────────────────────────────────────
# Slot Input Handlers
# ─────────────────────────────────────────────────────────────────────────────

func _on_slot_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed:
			if mb.button_index == MOUSE_BUTTON_LEFT:
				select_slot(index)
				if mb.shift_pressed:
					hotbar_slot_shift_clicked.emit(index)
				else:
					hotbar_slot_clicked.emit(index)
				_slot_panels[index].accept_event()
			elif mb.button_index == MOUSE_BUTTON_RIGHT:
				select_slot(index)
				if _inventory_open:
					hotbar_slot_right_clicked.emit(index)
				else:
					use_selected_item()
				_slot_panels[index].accept_event()


func _on_slot_mouse_entered(index: int) -> void:
	_slot_highlights[index].color = HOVER_TINT
	hotbar_slot_hovered.emit(index)


func _on_slot_mouse_exited(index: int) -> void:
	_slot_highlights[index].color = Color(1, 1, 1, 0)

# ─────────────────────────────────────────────────────────────────────────────
# Slot Refresh
# ─────────────────────────────────────────────────────────────────────────────

func _refresh_all_slots() -> void:
	for i in range(SLOT_COUNT):
		_refresh_slot(i)


func _refresh_slot(index: int) -> void:
	if index < 0 or index >= SLOT_COUNT:
		return
	if not _hotbar_data:
		_slot_icons[index].texture = null
		_slot_quantities[index].visible = false
		return

	var stack := _hotbar_data.get_slot(index)

	if stack and not stack.is_empty():
		if stack.item and stack.item.icon:
			_slot_icons[index].texture = stack.item.icon
		else:
			_slot_icons[index].texture = PlaceholderTextureCache.get_for_item(stack.item)

		if stack.quantity > 1:
			_slot_quantities[index].text = str(stack.quantity)
			_slot_quantities[index].visible = true
		else:
			_slot_quantities[index].visible = false
	else:
		_slot_icons[index].texture = null
		_slot_quantities[index].visible = false

# ─────────────────────────────────────────────────────────────────────────────
# Selection Visuals
# ─────────────────────────────────────────────────────────────────────────────

func _update_selection_visuals() -> void:
	for i in range(SLOT_COUNT):
		if i >= _slot_panels.size():
			continue

		var panel := _slot_panels[i]
		var style := panel.get_theme_stylebox("panel") as StyleBoxFlat

		if not style:
			continue

		# Clone the style to avoid shared mutation
		var new_style := style.duplicate() as StyleBoxFlat

		if i == _selected_index:
			new_style.border_color = SELECTED_BORDER_COLOR
			new_style.set_border_width_all(2)
			_slot_key_labels[i].add_theme_color_override("font_color", KEY_LABEL_SELECTED_COLOR)
		else:
			new_style.border_color = SLOT_BORDER_COLOR
			new_style.set_border_width_all(2)
			_slot_key_labels[i].add_theme_color_override("font_color", KEY_LABEL_COLOR)

		panel.add_theme_stylebox_override("panel", new_style)

# ─────────────────────────────────────────────────────────────────────────────
# Signal Handlers
# ─────────────────────────────────────────────────────────────────────────────

func _on_hotbar_changed() -> void:
	_refresh_all_slots()


func _on_slot_changed(slot_index: int) -> void:
	_refresh_slot(slot_index)
