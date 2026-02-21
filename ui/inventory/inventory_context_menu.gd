class_name InventoryContextMenu
extends PanelContainer
## Right-click context menu for inventory slots.
##
## Displays Use, Split, and Discard actions for the targeted slot.
## Emits signals back to the parent coordinator.

# ─────────────────────────────────────────────────────────────────────────────
# Signals
# ─────────────────────────────────────────────────────────────────────────────

## Emitted when the user clicks "Use" on an item.
signal use_requested(slot_index: int)

## Emitted when the user clicks "Split" on an item.
signal split_requested(slot_index: int)

## Emitted when the user clicks "Discard" on an item.
signal discard_requested(slot_index: int)

# ─────────────────────────────────────────────────────────────────────────────
# State
# ─────────────────────────────────────────────────────────────────────────────

var _active_slot_index: int = -1

# ─────────────────────────────────────────────────────────────────────────────
# Node Refs
# ─────────────────────────────────────────────────────────────────────────────

var _button_container: VBoxContainer

# ─────────────────────────────────────────────────────────────────────────────
# Lifecycle
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	_build_ui()

# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

## Shows the context menu for the given slot and item stack.
func show_for_slot(slot_index: int, stack: ItemStack, anchor_rect: Rect2) -> void:
	if stack == null or stack.is_empty():
		return

	_active_slot_index = slot_index

	# Clear old buttons
	for child in _button_container.get_children():
		child.queue_free()

	var item_definition := stack.item

	# Use action (label configured per-item in the resource)
	if item_definition.usable:
		_add_button(item_definition.get_use_label(), Color(0.3, 0.6, 0.35), _on_use_pressed)

	# Split action (available when stack has more than 1 item)
	if stack.quantity > 1:
		_add_button("Split", Color(0.3, 0.4, 0.6), _on_split_pressed)

	# Discard action (always available)
	_add_button("Discard", Color(0.6, 0.25, 0.25), _on_discard_pressed)

	visible = true
	reset_size()
	_position_near_rect(anchor_rect)


## Hides the context menu and resets state.
func hide_menu() -> void:
	visible = false
	_active_slot_index = -1


## Returns the slot index this menu is currently targeting.
func get_active_slot_index() -> int:
	return _active_slot_index

# ─────────────────────────────────────────────────────────────────────────────
# Build UI
# ─────────────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.13, 0.97)
	panel_style.set_border_width_all(1)
	panel_style.border_color = Color(0.4, 0.4, 0.5, 0.9)
	panel_style.set_corner_radius_all(6)
	panel_style.set_content_margin_all(6)
	add_theme_stylebox_override("panel", panel_style)

	_button_container = VBoxContainer.new()
	_button_container.add_theme_constant_override("separation", 2)
	add_child(_button_container)

# ─────────────────────────────────────────────────────────────────────────────
# Button Factory
# ─────────────────────────────────────────────────────────────────────────────

func _add_button(label_text: String, tint_color: Color, callback: Callable) -> void:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(120, 30)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT

	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(tint_color.r, tint_color.g, tint_color.b, 0.15)
	normal_style.set_corner_radius_all(3)
	normal_style.set_content_margin_all(6)
	button.add_theme_stylebox_override("normal", normal_style)

	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = Color(tint_color.r, tint_color.g, tint_color.b, 0.4)
	hover_style.set_corner_radius_all(3)
	hover_style.set_content_margin_all(6)
	button.add_theme_stylebox_override("hover", hover_style)

	button.add_theme_font_size_override("font_size", 14)
	button.pressed.connect(callback)
	_button_container.add_child(button)

# ─────────────────────────────────────────────────────────────────────────────
# Positioning
# ─────────────────────────────────────────────────────────────────────────────

func _position_near_rect(anchor_rect: Rect2) -> void:
	var popup_position := Vector2(
		anchor_rect.position.x + anchor_rect.size.x + 4,
		anchor_rect.position.y
	)

	var viewport_size := get_viewport().get_visible_rect().size
	var popup_size := size

	if popup_position.x + popup_size.x > viewport_size.x:
		popup_position.x = anchor_rect.position.x - popup_size.x - 4
	if popup_position.y + popup_size.y > viewport_size.y:
		popup_position.y = viewport_size.y - popup_size.y - 8

	position = popup_position

# ─────────────────────────────────────────────────────────────────────────────
# Button Callbacks
# ─────────────────────────────────────────────────────────────────────────────

func _on_use_pressed() -> void:
	var slot_index := _active_slot_index
	hide_menu()
	use_requested.emit(slot_index)


func _on_split_pressed() -> void:
	var slot_index := _active_slot_index
	hide_menu()
	split_requested.emit(slot_index)


func _on_discard_pressed() -> void:
	var slot_index := _active_slot_index
	hide_menu()
	discard_requested.emit(slot_index)
