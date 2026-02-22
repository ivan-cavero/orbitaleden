class_name DeathScreen
extends CanvasLayer
## Full-screen death overlay.
##
## Shows "You Died", the cause of death, and a Respawn button.
## Fades in over FADE_IN_DURATION seconds.
##
## Usage (main.gd):
##   death_screen.show_death(cause_of_death_string)
##   death_screen.respawn_pressed.connect(_on_respawn)

# ─────────────────────────────────────────────────────────────────────────────
# Signals
# ─────────────────────────────────────────────────────────────────────────────

## Emitted when the player presses the Respawn button.
signal respawn_pressed

# ─────────────────────────────────────────────────────────────────────────────
# Constants
# ─────────────────────────────────────────────────────────────────────────────

const FADE_IN_DURATION: float  = 1.8
const BG_COLOR: Color          = Color(0.0, 0.0, 0.0, 0.0)   # starts transparent
const TEXT_COLOR: Color        = Color(0.92, 0.15, 0.15, 1.0) # blood red
const CAUSE_COLOR: Color       = Color(0.78, 0.78, 0.82, 1.0)
const BTN_BG: Color            = Color(0.12, 0.12, 0.14, 0.9)
const BTN_BORDER: Color        = Color(0.55, 0.55, 0.60, 0.8)
const BTN_HOVER: Color         = Color(0.22, 0.22, 0.26, 0.95)

# ─────────────────────────────────────────────────────────────────────────────
# Private state
# ─────────────────────────────────────────────────────────────────────────────

var _bg: ColorRect      = null
var _title: Label       = null
var _cause: Label       = null
var _btn: Button        = null
var _fade_timer: float  = 0.0
var _fading: bool       = false

# ─────────────────────────────────────────────────────────────────────────────
# Lifecycle
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	# Hidden until show_death() is called.
	visible = false


func _process(delta: float) -> void:
	if not _fading:
		return
	_fade_timer += delta
	var t := clampf(_fade_timer / FADE_IN_DURATION, 0.0, 1.0)
	_bg.color = Color(0.0, 0.0, 0.0, t * 0.88)
	# Text and button fade in slightly after the background.
	var content_alpha := clampf((t - 0.35) / 0.65, 0.0, 1.0)
	_title.modulate.a = content_alpha
	_cause.modulate.a = content_alpha
	_btn.modulate.a   = content_alpha
	if t >= 1.0:
		_fading = false


# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

## Display the death screen with the given cause string.
## Releases mouse input and pauses player movement via PROCESS_MODE_ALWAYS.
func show_death(cause: String) -> void:
	_cause.text = cause
	_title.modulate.a = 0.0
	_cause.modulate.a = 0.0
	_btn.modulate.a   = 0.0
	_bg.color = Color(0.0, 0.0, 0.0, 0.0)
	_fade_timer = 0.0
	_fading = true
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


## Hide the death screen (called after respawn).
func hide_death() -> void:
	visible = false
	_fading = false


# ─────────────────────────────────────────────────────────────────────────────
# UI construction
# ─────────────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	# Full-screen dark background.
	_bg = ColorRect.new()
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bg.color = Color.TRANSPARENT
	add_child(_bg)

	# Centred VBox for all content.
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(vbox)

	# "YOU DIED" title.
	_title = Label.new()
	_title.text = "YOU DIED"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 56)
	_title.add_theme_color_override("font_color", TEXT_COLOR)
	_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_title.add_theme_constant_override("shadow_offset_x", 3)
	_title.add_theme_constant_override("shadow_offset_y", 3)
	_title.modulate.a = 0.0
	vbox.add_child(_title)

	# Cause of death label.
	_cause = Label.new()
	_cause.text = ""
	_cause.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cause.add_theme_font_size_override("font_size", 18)
	_cause.add_theme_color_override("font_color", CAUSE_COLOR)
	_cause.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_cause.add_theme_constant_override("shadow_offset_x", 1)
	_cause.add_theme_constant_override("shadow_offset_y", 1)
	_cause.modulate.a = 0.0
	vbox.add_child(_cause)

	# Spacer.
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 24)
	vbox.add_child(spacer)

	# Respawn button.
	_btn = Button.new()
	_btn.text = "Respawn"
	_btn.custom_minimum_size = Vector2(180, 44)
	_btn.add_theme_font_size_override("font_size", 16)
	_btn.modulate.a = 0.0

	var style_normal := StyleBoxFlat.new()
	style_normal.bg_color = BTN_BG
	style_normal.border_color = BTN_BORDER
	style_normal.set_border_width_all(1)
	style_normal.set_corner_radius_all(6)
	style_normal.content_margin_left   = 16
	style_normal.content_margin_right  = 16
	style_normal.content_margin_top    = 10
	style_normal.content_margin_bottom = 10

	var style_hover := StyleBoxFlat.new()
	style_hover.bg_color = BTN_HOVER
	style_hover.border_color = BTN_BORDER
	style_hover.set_border_width_all(1)
	style_hover.set_corner_radius_all(6)
	style_hover.content_margin_left   = 16
	style_hover.content_margin_right  = 16
	style_hover.content_margin_top    = 10
	style_hover.content_margin_bottom = 10

	_btn.add_theme_stylebox_override("normal",  style_normal)
	_btn.add_theme_stylebox_override("hover",   style_hover)
	_btn.add_theme_stylebox_override("pressed", style_hover)
	_btn.add_theme_stylebox_override("focus",   style_normal)
	_btn.add_theme_color_override("font_color",        Color(0.9, 0.9, 0.95, 1.0))
	_btn.add_theme_color_override("font_hover_color",  Color(1.0, 1.0, 1.0, 1.0))
	_btn.pressed.connect(_on_respawn_pressed)
	vbox.add_child(_btn)


func _on_respawn_pressed() -> void:
	respawn_pressed.emit()
