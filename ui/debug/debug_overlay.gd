class_name DebugOverlay
extends CanvasLayer
## Minimal performance overlay. Toggle with F3.

# ── Constants ────────────────────────────────────────────────────────────────
const UPDATE_INTERVAL := 0.25

# ── State ────────────────────────────────────────────────────────────────────
var _open        := false
var _timer       := 0.0

# ── Node refs ────────────────────────────────────────────────────────────────
@onready var _panel: PanelContainer = $Panel
@onready var _label: RichTextLabel  = $Panel/Margin/Content


# ── Lifecycle ────────────────────────────────────────────────────────────────
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel.visible = false


func _process(delta: float) -> void:
	if not _open:
		return
	_timer += delta
	if _timer >= UPDATE_INTERVAL:
		_timer = 0.0
		_refresh()


# ── Input ────────────────────────────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_overlay"):
		get_viewport().set_input_as_handled()
		if _open:
			close()
		else:
			open()


# ── Public API ───────────────────────────────────────────────────────────────
func open() -> void:
	if _open:
		return
	_open = true
	_panel.visible = true
	_refresh()


func close() -> void:
	if not _open:
		return
	_open = false
	_panel.visible = false


func is_open() -> bool:
	return _open


# ── Display ──────────────────────────────────────────────────────────────────
func _refresh() -> void:
	var fps       := Engine.get_frames_per_second()
	var ms        := 1000.0 / fps if fps > 0 else 0.0
	var mem       := Performance.get_monitor(Performance.MEMORY_STATIC)
	var nodes     := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	var vp        := get_viewport()
	var obj_count := vp.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_OBJECTS_IN_FRAME)
	var draws     := vp.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME)

	var fps_col := "#5d5" if fps >= 60 else ("#fc0" if fps >= 30 else "#f55")

	_label.text = (
		"[color=%s]%d fps[/color]  %.1f ms\n" % [fps_col, fps, ms]
		+ "%d obj  %d draws\n" % [obj_count, draws]
		+ "%s  %d nodes" % [_fmt_bytes(mem), nodes]
	)


func _fmt_bytes(b: float) -> String:
	if b < 1_048_576.0:
		return "%.0f KB" % (b / 1024.0)
	return "%.1f MB" % (b / 1_048_576.0)
