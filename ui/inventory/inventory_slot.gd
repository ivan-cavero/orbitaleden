class_name InventorySlot
extends PanelContainer
## A single inventory slot that displays an item icon and quantity.
##
## Handles click events for drag-and-drop and stack splitting.
## Emits signals consumed by InventoryUI to coordinate slot operations.

# ─────────────────────────────────────────────────────────────────────────────
# Signals
# ─────────────────────────────────────────────────────────────────────────────

## Left-click on this slot.
signal slot_clicked(slot_index: int)

## Shift + left-click on this slot (quick-move to hotbar).
signal slot_shift_clicked(slot_index: int)

## Right-click on this slot (context menu).
signal slot_right_clicked(slot_index: int)

## Shift + right-click on this slot (split stack).
signal slot_shift_right_clicked(slot_index: int)

## Mouse entered this slot (for drag target detection).
signal slot_hovered(slot_index: int)

# ─────────────────────────────────────────────────────────────────────────────
# Constants
# ─────────────────────────────────────────────────────────────────────────────

const SLOT_SIZE := Vector2(64, 64)
const ICON_SIZE := Vector2(48, 48)

# ─────────────────────────────────────────────────────────────────────────────
# Internal State
# ─────────────────────────────────────────────────────────────────────────────

var slot_index: int = -1
var _stack: ItemStack = null
var _is_hovered: bool = false
var _is_selected: bool = false

# ─────────────────────────────────────────────────────────────────────────────
# Node Refs
# ─────────────────────────────────────────────────────────────────────────────

var _icon: TextureRect
var _quantity_label: Label
var _highlight: ColorRect

# ─────────────────────────────────────────────────────────────────────────────
# Lifecycle
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	custom_minimum_size = SLOT_SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	_apply_style()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed:
			if mb.button_index == MOUSE_BUTTON_LEFT:
				if mb.shift_pressed:
					slot_shift_clicked.emit(slot_index)
				else:
					slot_clicked.emit(slot_index)
				accept_event()
			elif mb.button_index == MOUSE_BUTTON_RIGHT:
				if mb.shift_pressed:
					slot_shift_right_clicked.emit(slot_index)
				else:
					slot_right_clicked.emit(slot_index)
				accept_event()

# ─────────────────────────────────────────────────────────────────────────────
# Mouse Hover
# ─────────────────────────────────────────────────────────────────────────────

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		_is_hovered = true
		_update_highlight()
		slot_hovered.emit(slot_index)
	elif what == NOTIFICATION_MOUSE_EXIT:
		_is_hovered = false
		_update_highlight()

# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

## Updates the slot display with a given ItemStack (or null for empty).
func set_stack(stack: ItemStack) -> void:
	_stack = stack
	_refresh_display()


## Returns the current stack (may be null).
func get_stack() -> ItemStack:
	return _stack


## Returns true if the slot contains an item.
func has_item() -> bool:
	return _stack != null and not _stack.is_empty()


## Sets visual selection state.
func set_selected(selected: bool) -> void:
	_is_selected = selected
	_update_highlight()


## Returns the item definition for tooltips.
func get_item_definition() -> ItemDefinition:
	if _stack and _stack.item:
		return _stack.item
	return null

# ─────────────────────────────────────────────────────────────────────────────
# Build UI
# ─────────────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	# Icon centered in slot via anchors (no manual position/size — let the
	# PanelContainer's layout manage placement through the anchor preset).
	_icon = TextureRect.new()
	_icon.custom_minimum_size = ICON_SIZE
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_icon)

	# Quantity label at bottom-right
	_quantity_label = Label.new()
	_quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_quantity_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_quantity_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_quantity_label.offset_right = -4
	_quantity_label.offset_bottom = -2
	_quantity_label.add_theme_font_size_override("font_size", 14)
	_quantity_label.add_theme_color_override("font_color", Color.WHITE)
	_quantity_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_quantity_label.add_theme_constant_override("shadow_offset_x", 1)
	_quantity_label.add_theme_constant_override("shadow_offset_y", 1)
	_quantity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_quantity_label)

	# Highlight overlay
	_highlight = ColorRect.new()
	_highlight.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_highlight.color = Color(1, 1, 1, 0)
	_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_highlight)

# ─────────────────────────────────────────────────────────────────────────────
# Style
# ─────────────────────────────────────────────────────────────────────────────

func _apply_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.15, 0.9)
	style.set_border_width_all(1)
	style.border_color = Color(0.3, 0.3, 0.35, 0.8)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(2)
	add_theme_stylebox_override("panel", style)

# ─────────────────────────────────────────────────────────────────────────────
# Display Refresh
# ─────────────────────────────────────────────────────────────────────────────

func _refresh_display() -> void:
	if _stack and not _stack.is_empty():
		# Show icon
		if _stack.item and _stack.item.icon:
			_icon.texture = _stack.item.icon
		else:
			_icon.texture = PlaceholderTextureCache.get_for_item(_stack.item)

		# Show quantity (hide if 1)
		if _stack.quantity > 1:
			_quantity_label.text = str(_stack.quantity)
			_quantity_label.visible = true
		else:
			_quantity_label.visible = false
	else:
		_icon.texture = null
		_quantity_label.visible = false


func _update_highlight() -> void:
	if not _highlight:
		return

	if _is_selected:
		_highlight.color = Color(1, 1, 0.5, 0.15)
	elif _is_hovered:
		_highlight.color = Color(1, 1, 1, 0.1)
	else:
		_highlight.color = Color(1, 1, 1, 0)
