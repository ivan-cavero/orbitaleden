class_name InventoryTooltip
extends PanelContainer
## Floating tooltip that shows item details on hover.
##
## Used by InventoryUI for both inventory slots and hotbar slots.
## Call show_for_item() to display, hide_tooltip() to dismiss,
## and update_position() each frame while visible.

# ─────────────────────────────────────────────────────────────────────────────
# Constants
# ─────────────────────────────────────────────────────────────────────────────

const CURSOR_OFFSET := Vector2(16, 16)

# ─────────────────────────────────────────────────────────────────────────────
# Node Refs
# ─────────────────────────────────────────────────────────────────────────────

var _name_label: Label
var _description_label: Label
var _info_label: Label

# ─────────────────────────────────────────────────────────────────────────────
# Lifecycle
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_build_ui()

# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

## Shows the tooltip populated with the given item's details.
func show_for_item(item_definition: ItemDefinition) -> void:
	if item_definition == null:
		hide_tooltip()
		return

	_name_label.text = item_definition.display_name

	if item_definition.description.is_empty():
		_description_label.visible = false
	else:
		_description_label.text = item_definition.description
		_description_label.visible = true

	var info_parts: Array[String] = []
	info_parts.append(ItemDefinition.get_category_name(item_definition.category))
	info_parts.append("Tier %d" % item_definition.tier)
	info_parts.append("Stack: %d" % item_definition.stack_size)
	_info_label.text = " | ".join(info_parts)

	visible = true
	_reposition_to_cursor()


## Hides the tooltip.
func hide_tooltip() -> void:
	visible = false


## Updates position to follow the mouse cursor. Call from _input on mouse motion.
func update_position() -> void:
	if visible:
		_reposition_to_cursor()

# ─────────────────────────────────────────────────────────────────────────────
# Build UI
# ─────────────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.05, 0.08, 0.95)
	panel_style.set_border_width_all(1)
	panel_style.border_color = Color(0.4, 0.4, 0.5, 0.8)
	panel_style.set_corner_radius_all(4)
	panel_style.set_content_margin_all(10)
	add_theme_stylebox_override("panel", panel_style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	add_child(vbox)

	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 16)
	_name_label.add_theme_color_override("font_color", Color(1, 0.85, 0.4))
	vbox.add_child(_name_label)

	_description_label = Label.new()
	_description_label.add_theme_font_size_override("font_size", 13)
	_description_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_description_label.custom_minimum_size.x = 200
	vbox.add_child(_description_label)

	_info_label = Label.new()
	_info_label.add_theme_font_size_override("font_size", 12)
	_info_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	vbox.add_child(_info_label)

# ─────────────────────────────────────────────────────────────────────────────
# Positioning
# ─────────────────────────────────────────────────────────────────────────────

func _reposition_to_cursor() -> void:
	reset_size()

	var mouse_position := get_global_mouse_position()
	var tooltip_position := mouse_position + CURSOR_OFFSET
	var viewport_size := get_viewport().get_visible_rect().size
	var tooltip_size := size

	if tooltip_position.x + tooltip_size.x > viewport_size.x:
		tooltip_position.x = mouse_position.x - tooltip_size.x - 8
	if tooltip_position.y + tooltip_size.y > viewport_size.y:
		tooltip_position.y = mouse_position.y - tooltip_size.y - 8

	position = tooltip_position
