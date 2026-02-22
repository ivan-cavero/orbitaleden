class_name StatsHUD
extends CanvasLayer
## Bottom-left HUD panel showing survival stat bars.
##
## Six bars: Health (red), Oxygen (blue), Hunger (orange),
## Thirst (cyan), Sanity (purple), Stamina (yellow).
## Stamina bar is hidden when full; appears when the player starts spending it.
## Bars flash when a stat drops below the critical threshold (< 20%).
##
## Usage (main.gd):
##   hud.setup(player.get_node("Survival"))

# ─────────────────────────────────────────────────────────────────────────────
# Constants — colours and layout
# ─────────────────────────────────────────────────────────────────────────────

const BG_COLOR     := Color(0.06, 0.06, 0.08, 0.82)
const BORDER_COLOR := Color(0.3,  0.3,  0.35, 0.8)

## Stat colours (normal fill).
const STAT_COLORS := {
	"health":  Color(0.80, 0.20, 0.20, 1.0),  # red
	"oxygen":  Color(0.25, 0.55, 0.95, 1.0),  # blue
	"hunger":  Color(0.90, 0.55, 0.15, 1.0),  # orange
	"thirst":  Color(0.20, 0.80, 0.85, 1.0),  # cyan
	"sanity":  Color(0.65, 0.30, 0.90, 1.0),  # purple
	"stamina": Color(0.90, 0.85, 0.20, 1.0),  # yellow
}

## Short labels shown left of each bar.
const STAT_LABELS := {
	"health":  "HP",
	"oxygen":  "O2",
	"hunger":  "HNG",
	"thirst":  "THR",
	"sanity":  "SAN",
	"stamina": "STM",
}

## Stat order top-to-bottom.
const STAT_ORDER: Array[String] = ["health", "oxygen", "hunger", "thirst", "sanity", "stamina"]

## Below this ratio the bar flashes.
const CRITICAL_THRESHOLD: float = 0.2

## Flash period (seconds for one full on→off→on cycle).
const FLASH_PERIOD: float = 0.6

## Bar dimensions.
const BAR_WIDTH:  float = 120.0
const BAR_HEIGHT: float = 6.0

## Panel left/bottom margin from screen edge.
const MARGIN_LEFT:   float = 12.0
const MARGIN_BOTTOM: float = 12.0

## Gap between rows.
const ROW_GAP: float = 5.0

# ─────────────────────────────────────────────────────────────────────────────
# Private state
# ─────────────────────────────────────────────────────────────────────────────

var _survival: Node = null

## Per-stat UI refs: { stat_name → { "row": Control, "fill": ColorRect, "label": Label } }
var _bars: Dictionary = {}

## Running time for flash animation.
var _flash_timer: float = 0.0

## Whether numeric values are shown next to bars.
var _show_numbers: bool = true

var _root: Control = null

## Popup labels for use-feedback: Array of {label: Label, timer: float}
var _popups: Array = []

const POPUP_DURATION: float = 1.8

# ─────────────────────────────────────────────────────────────────────────────
# Lifecycle
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()


func _process(delta: float) -> void:
	_flash_timer += delta
	_refresh()
	_tick_popups(delta)


# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

## Connect this HUD to the player's Survival node.
func setup(survival: Node) -> void:
	_survival = survival


## Toggle numeric values next to bars.
func toggle_numbers() -> void:
	_show_numbers = not _show_numbers
	for stat in STAT_ORDER:
		if _bars.has(stat):
			(_bars[stat]["label"] as Label).visible = _show_numbers


## Show a brief floating "+N stat" label above the HUD panel.
## Called by main.gd after a consumable is used.
func show_restore_feedback(stat: String, amount: float) -> void:
	if not _bars.has(stat):
		return
	var color: Color = STAT_COLORS.get(stat, Color.WHITE)
	var lbl := Label.new()
	lbl.text = "+%.0f %s" % [amount, STAT_LABELS.get(stat, stat.to_upper())]
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(lbl)
	# Position near the panel (will be updated in _tick_popups)
	_popups.append({"label": lbl, "timer": 0.0})


# ─────────────────────────────────────────────────────────────────────────────
# UI construction
# ─────────────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	# Anchor root control to bottom-left.
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	# Outer panel.
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	style.set_border_width_all(1)
	style.border_color = BORDER_COLOR
	style.set_corner_radius_all(6)
	style.content_margin_left   = 10
	style.content_margin_right  = 10
	style.content_margin_top    = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	_root.add_child(panel)

	# VBox holding all rows.
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", int(ROW_GAP))
	panel.add_child(vbox)

	# Build one row per stat.
	for stat in STAT_ORDER:
		var row := _build_row(stat)
		vbox.add_child(row)
		# Stamina row starts hidden (shown only when not full).
		if stat == "stamina":
			row.visible = false

	# Position panel: bottom-left with margins.
	# We reposition in _refresh() once the panel has a known size.
	panel.position = Vector2(MARGIN_LEFT, -999)  # will be corrected first frame


func _build_row(stat: String) -> HBoxContainer:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Stat abbreviation label.
	var name_label := Label.new()
	name_label.text = STAT_LABELS[stat]
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75, 0.9))
	name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	name_label.add_theme_constant_override("shadow_offset_x", 1)
	name_label.add_theme_constant_override("shadow_offset_y", 1)
	name_label.custom_minimum_size = Vector2(28, 0)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(name_label)

	# Bar background + fill container.
	var bar_bg := ColorRect.new()
	bar_bg.custom_minimum_size = Vector2(BAR_WIDTH, BAR_HEIGHT)
	bar_bg.color = Color(0.15, 0.15, 0.18, 0.9)
	bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var fill := ColorRect.new()
	fill.color = STAT_COLORS[stat]
	fill.size = Vector2(BAR_WIDTH, BAR_HEIGHT)
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar_bg.add_child(fill)
	hbox.add_child(bar_bg)

	# Numeric value label (optional).
	var val_label := Label.new()
	val_label.add_theme_font_size_override("font_size", 11)
	val_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9, 0.85))
	val_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	val_label.add_theme_constant_override("shadow_offset_x", 1)
	val_label.add_theme_constant_override("shadow_offset_y", 1)
	val_label.custom_minimum_size = Vector2(36, 0)
	val_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(val_label)

	_bars[stat] = {
		"row":   hbox,
		"fill":  fill,
		"bg":    bar_bg,
		"label": val_label,
	}
	return hbox


# ─────────────────────────────────────────────────────────────────────────────
# Per-frame refresh
# ─────────────────────────────────────────────────────────────────────────────

func _refresh() -> void:
	if not is_instance_valid(_survival) or not _survival.has_method("get_debug_snapshot"):
		return

	var snap: Dictionary = _survival.get_debug_snapshot()

	# Flash: true for the "bright" half of the cycle.
	var flash_bright: bool = fmod(_flash_timer, FLASH_PERIOD) < (FLASH_PERIOD * 0.5)

	for stat in STAT_ORDER:
		if not _bars.has(stat) or not snap.has(stat):
			continue

		var pair: Array  = snap[stat]
		var current: float = float(pair[0])
		var maximum: float = float(pair[1])
		var ratio: float   = (current / maximum) if maximum > 0.0 else 0.0

		var bar_data: Dictionary = _bars[stat]
		var fill: ColorRect  = bar_data["fill"]
		var label: Label     = bar_data["label"]
		var row: Control     = bar_data["row"]

		# Stamina row: only visible when stamina is not full.
		if stat == "stamina":
			row.visible = ratio < 0.999

		# Bar fill width.
		var bg: ColorRect = bar_data["bg"]
		fill.size.x = bg.size.x * clampf(ratio, 0.0, 1.0)

		# Numeric label.
		if _show_numbers:
			label.text = "%d" % int(current)

		# Colour: flash red when critical, otherwise normal stat colour.
		if ratio < CRITICAL_THRESHOLD and flash_bright:
			fill.color = Color(0.85, 0.15, 0.15, 1.0)
		else:
			fill.color = STAT_COLORS[stat]

	# Position panel bottom-left (needs to run each frame until size is stable).
	_reposition_panel()


func _reposition_panel() -> void:
	if _root.get_child_count() == 0:
		return
	var panel: Control = _root.get_child(0)
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	panel.position = Vector2(
		MARGIN_LEFT,
		vp_size.y - panel.size.y - MARGIN_BOTTOM
	)


func _tick_popups(delta: float) -> void:
	if _popups.is_empty():
		return
	if _root.get_child_count() == 0:
		return
	var panel: Control = _root.get_child(0)
	var base_y: float = panel.position.y - 4.0

	var i := _popups.size() - 1
	while i >= 0:
		var entry: Dictionary = _popups[i]
		entry["timer"] += delta
		var t: float = entry["timer"] / POPUP_DURATION
		var lbl: Label = entry["label"]
		# Float upward and fade out.
		lbl.position = Vector2(panel.position.x, base_y - t * 24.0)
		lbl.modulate.a = 1.0 - t
		if entry["timer"] >= POPUP_DURATION:
			lbl.queue_free()
			_popups.remove_at(i)
		i -= 1
