class_name InventorySplitMenu
extends PanelContainer
## Shift+Right-click split menu for inventory slots.
##
## Shows a slider, spin box, and preset buttons to choose how many items
## to split from a stack. Emits split_confirmed with the amount.

# ─────────────────────────────────────────────────────────────────────────────
# Signals
# ─────────────────────────────────────────────────────────────────────────────

## Emitted when the user confirms a split. Amount is clamped to [1, stack-1].
signal split_confirmed(slot_index: int, amount: int)

# ─────────────────────────────────────────────────────────────────────────────
# State
# ─────────────────────────────────────────────────────────────────────────────

var _active_slot_index: int = -1
var _source_quantity: int = 0

# ─────────────────────────────────────────────────────────────────────────────
# Node Refs
# ─────────────────────────────────────────────────────────────────────────────

var _amount_label: Label
var _slider: HSlider
var _spin_box: SpinBox
var _confirm_button: Button

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

## Shows the split menu for the given slot and stack.
func show_for_slot(slot_index: int, stack: ItemStack, anchor_rect: Rect2) -> void:
	if stack == null or stack.is_empty() or stack.quantity <= 1:
		return

	_active_slot_index = slot_index
	_source_quantity = stack.quantity

	var max_split := stack.quantity - 1  # Must leave at least 1
	_slider.min_value = 1
	_slider.max_value = max_split
	_slider.value = ceili(max_split / 2.0)
	_spin_box.min_value = 1
	_spin_box.max_value = max_split
	_spin_box.value = _slider.value
	_update_amount_label()

	visible = true
	reset_size()
	_position_near_rect(anchor_rect)


## Hides the split menu and resets state.
func hide_menu() -> void:
	visible = false
	_active_slot_index = -1
	_source_quantity = 0


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
	panel_style.border_color = Color(0.35, 0.45, 0.6, 0.9)
	panel_style.set_corner_radius_all(6)
	panel_style.set_content_margin_all(12)
	add_theme_stylebox_override("panel", panel_style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.custom_minimum_size.x = 220
	add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "Split Stack"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Amount label ("Take X / Y")
	_amount_label = Label.new()
	_amount_label.add_theme_font_size_override("font_size", 13)
	_amount_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	_amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_amount_label)

	# Slider
	_slider = HSlider.new()
	_slider.min_value = 1
	_slider.max_value = 99
	_slider.step = 1
	_slider.custom_minimum_size.y = 20
	_slider.value_changed.connect(_on_slider_value_changed)
	vbox.add_child(_slider)

	# Input row
	var input_row := HBoxContainer.new()
	input_row.add_theme_constant_override("separation", 4)
	vbox.add_child(input_row)

	_spin_box = SpinBox.new()
	_spin_box.min_value = 1
	_spin_box.max_value = 99
	_spin_box.step = 1
	_spin_box.custom_minimum_size.x = 70
	_spin_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_spin_box.value_changed.connect(_on_spin_box_value_changed)
	input_row.add_child(_spin_box)

	# Preset buttons row
	_build_preset_buttons(vbox)

	# Confirm button
	_confirm_button = Button.new()
	_confirm_button.text = "Split"
	_confirm_button.custom_minimum_size = Vector2(0, 32)
	_confirm_button.pressed.connect(_on_confirm_pressed)
	var confirm_normal := StyleBoxFlat.new()
	confirm_normal.bg_color = Color(0.2, 0.5, 0.3, 0.9)
	confirm_normal.set_corner_radius_all(4)
	confirm_normal.set_content_margin_all(4)
	_confirm_button.add_theme_stylebox_override("normal", confirm_normal)
	var confirm_hover := StyleBoxFlat.new()
	confirm_hover.bg_color = Color(0.3, 0.6, 0.4, 0.9)
	confirm_hover.set_corner_radius_all(4)
	confirm_hover.set_content_margin_all(4)
	_confirm_button.add_theme_stylebox_override("hover", confirm_hover)
	vbox.add_child(_confirm_button)


func _build_preset_buttons(parent: VBoxContainer) -> void:
	var presets_row := HBoxContainer.new()
	presets_row.add_theme_constant_override("separation", 4)
	parent.add_child(presets_row)

	var preset_data := [["1", 0.0], ["1/4", 0.25], ["1/2", 0.5], ["3/4", 0.75], ["All", 1.0]]
	for entry in preset_data:
		var button := Button.new()
		button.text = entry[0]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, 28)

		var normal_style := StyleBoxFlat.new()
		normal_style.bg_color = Color(0.18, 0.25, 0.35, 0.9)
		normal_style.set_corner_radius_all(3)
		normal_style.set_content_margin_all(2)
		button.add_theme_stylebox_override("normal", normal_style)

		var hover_style := StyleBoxFlat.new()
		hover_style.bg_color = Color(0.25, 0.35, 0.5, 0.9)
		hover_style.set_corner_radius_all(3)
		hover_style.set_content_margin_all(2)
		button.add_theme_stylebox_override("hover", hover_style)

		button.add_theme_font_size_override("font_size", 12)
		var fraction: float = entry[1]
		button.pressed.connect(_on_preset_pressed.bind(fraction))
		presets_row.add_child(button)

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
# Internal Callbacks
# ─────────────────────────────────────────────────────────────────────────────

func _update_amount_label() -> void:
	var take := int(_slider.value)
	_amount_label.text = "Take %d / %d" % [take, _source_quantity]


func _on_slider_value_changed(value: float) -> void:
	_spin_box.value = value
	_update_amount_label()


func _on_spin_box_value_changed(value: float) -> void:
	_slider.value = value
	_update_amount_label()


func _on_preset_pressed(fraction: float) -> void:
	var max_split := _source_quantity - 1
	var amount: int
	if fraction <= 0.0:
		amount = 1
	elif fraction >= 1.0:
		amount = max_split
	else:
		amount = clampi(int(_source_quantity * fraction), 1, max_split)

	_slider.value = amount
	_spin_box.value = amount
	_update_amount_label()


func _on_confirm_pressed() -> void:
	var slot_index := _active_slot_index
	var amount := clampi(int(_slider.value), 1, _source_quantity - 1)
	hide_menu()
	split_confirmed.emit(slot_index, amount)
