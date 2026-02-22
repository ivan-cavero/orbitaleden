class_name DebugOverlay
extends CanvasLayer
## Structured six-panel debug overlay. Toggle with F3.

# ── Constants ────────────────────────────────────────────────────────────────
const UPDATE_INTERVAL := 0.25

const COLOR_TITLE := "#b9c6f3"
const COLOR_DIM := "#8a8f9c"
const COLOR_OK := "#6d6"
const COLOR_WARN := "#fc0"
const COLOR_BAD := "#f66"

const PANEL_WIDTH := 330
const PANEL_GAP := 8

# ── State ────────────────────────────────────────────────────────────────────
var _open        := false
var _timer       := 0.0
var _player: Node = null

# ── UI refs ─────────────────────────────────────────────────────────────────
var _root: Control
var _left_column: VBoxContainer
var _right_column: VBoxContainer
var _panel_labels: Dictionary = {}


# ── Lifecycle ────────────────────────────────────────────────────────────────
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_open = false
	if is_instance_valid(_root):
		_root.visible = false


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
	if is_instance_valid(_root):
		_root.visible = true
	_refresh()


func close() -> void:
	if not _open:
		return
	_open = false
	if is_instance_valid(_root):
		_root.visible = false


func is_open() -> bool:
	return _open


# ── Display ──────────────────────────────────────────────────────────────────
func _refresh() -> void:
	_resolve_player()

	var fps := Engine.get_frames_per_second()
	var fps_int := int(round(fps))
	var frame_ms := 1000.0 / fps if fps > 0 else 0.0
	var process_ms := Performance.get_monitor(Performance.TIME_PROCESS)
	var physics_ms := Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	var cpu_frame_ms := process_ms + physics_ms
	var cpu_load := (cpu_frame_ms / frame_ms) * 100.0 if frame_ms > 0.0 else 0.0
	cpu_load = clampf(cpu_load, 0.0, 999.0)

	var ram_static := Performance.get_monitor(Performance.MEMORY_STATIC)
	var ram_static_peak := Performance.get_monitor(Performance.MEMORY_STATIC_MAX)
	var system_ram_total := _get_system_ram_total_bytes()
	var vram := Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	var tex_mem := Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)
	var buf_mem := Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED)

	var resource_count := int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))
	var nodes := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	var orphan_nodes := int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))

	var vp := get_viewport()
	var visible_objects := vp.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_OBJECTS_IN_FRAME)
	var visible_primitives := vp.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_PRIMITIVES_IN_FRAME)
	var draws := vp.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME)

	var total_primitives := Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	var total_draws := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)

	var phys3d_active := int(Performance.get_monitor(Performance.PHYSICS_3D_ACTIVE_OBJECTS))
	var phys3d_pairs := int(Performance.get_monitor(Performance.PHYSICS_3D_COLLISION_PAIRS))
	var phys3d_islands := int(Performance.get_monitor(Performance.PHYSICS_3D_ISLAND_COUNT))

	var win_size := DisplayServer.window_get_size()
	var viewport_size := vp.get_visible_rect().size
	var world_items := get_tree().get_nodes_in_group("world_item").size()
	var interactables := get_tree().get_nodes_in_group("interactable").size()

	var fps_col := _fps_color(fps)
	var frame_col := _frame_time_color(frame_ms)
	var cpu_col := _cpu_color(cpu_load)
	var mem_col := _mem_color(ram_static, system_ram_total, ram_static_peak)
	var ram_peak_delta := maxf(ram_static_peak - ram_static, 0.0)
	var draw_col := _draw_color(draws)
	var system_ratio := (ram_static / system_ram_total) if system_ram_total > 0.0 else -1.0
	var system_ratio_text := "n/a" if system_ratio < 0.0 else "%.2f %%" % (system_ratio * 100.0)

	var perf_rows: Array = [
		["FPS", str(fps_int), fps_col],
		["Frame time", "%.2f ms" % frame_ms, frame_col],
		["Game CPU", "%.1f %%" % cpu_load, cpu_col],
		["Process", "%.2f ms" % process_ms],
		["Physics", "%.2f ms" % physics_ms],
	]

	var render_rows: Array = [
		["Visible objects", str(visible_objects)],
		["Visible triangles", _fmt_int(visible_primitives)],
		["Visible draw calls", str(draws), draw_col],
		["Total triangles", _fmt_int(total_primitives)],
		["Total draw calls", _fmt_int(total_draws)],
		["Window / Viewport", "%dx%d / %.0fx%.0f" % [win_size.x, win_size.y, viewport_size.x, viewport_size.y]],
	]

	var memory_rows: Array = [
		["Godot static RAM", _fmt_bytes(ram_static), mem_col],
		["Godot local peak", _fmt_bytes(ram_static_peak)],
		["Headroom to local peak", _fmt_bytes(ram_peak_delta), COLOR_DIM],
		["System RAM total", _fmt_bytes(system_ram_total)],
		["Godot / System", system_ratio_text, mem_col],
		["VRAM total", _fmt_bytes(vram)],
		["Texture memory", _fmt_bytes(tex_mem)],
		["Buffer memory", _fmt_bytes(buf_mem)],
	]

	var player_rows := _get_player_rows()
	var survival_rows := _get_survival_rows()

	var physics_rows: Array = [
		["Active objects", str(phys3d_active)],
		["Collision pairs", str(phys3d_pairs)],
		["Islands", str(phys3d_islands)],
	]

	var world_rows: Array = [
		["Interactables", str(interactables)],
		["World items", str(world_items)],
		["Nodes", _fmt_int(nodes)],
		["Resources", _fmt_int(resource_count)],
		["Orphans", _fmt_int(orphan_nodes), COLOR_WARN if orphan_nodes > 0 else COLOR_OK],
		["UI blocks input", _on_off(Debug.is_ui_blocking())],
	]

	_set_panel_content("performance", "PERFORMANCE", perf_rows)
	_set_panel_content("render", "RENDER", render_rows)
	_set_panel_content("memory", "MEMORY", memory_rows)
	_set_panel_content("player", "PLAYER", player_rows)
	_set_panel_content("survival", "SURVIVAL [DEBUG]", survival_rows)
	_set_panel_content("physics", "PHYSICS 3D", physics_rows)
	_set_panel_content("world", "WORLD", world_rows)


func _get_player_rows() -> Array:
	if not is_instance_valid(_player) or not _player.has_method("get_debug_snapshot"):
		return [["Status", "PlayerController not found", COLOR_WARN]]

	var d: Dictionary = _player.get_debug_snapshot()
	var pos: Vector3 = d.get("position", Vector3.ZERO)
	var vel: Vector3 = d.get("velocity", Vector3.ZERO)
	var look: Vector3 = d.get("look_forward", Vector3.FORWARD)
	var horiz_speed: float = d.get("horizontal_speed", 0.0)
	var yaw_deg: float = d.get("yaw_deg", 0.0)
	var pitch_deg: float = d.get("pitch_deg", 0.0)

	var speed_col := COLOR_OK if horiz_speed < 7.0 else (COLOR_WARN if horiz_speed < 14.0 else COLOR_BAD)
	return [
		["Position", "X %.2f  Y %.2f  Z %.2f" % [pos.x, pos.y, pos.z]],
		["Velocity", "X %.2f  Y %.2f  Z %.2f" % [vel.x, vel.y, vel.z]],
		["Speed", "%.2f m/s" % vel.length(), speed_col],
		["Horizontal speed", "%.2f m/s" % horiz_speed, speed_col],
		["Look", "yaw %.1f deg  pitch %.1f deg" % [yaw_deg, pitch_deg]],
		["Forward", "X %.2f  Y %.2f  Z %.2f" % [look.x, look.y, look.z]],
		["State", "%s  floor:%s  crouch:%s  sprint:%s" % [
			str(d.get("mode", "NORMAL")),
			_on_off(bool(d.get("on_floor", false))),
			_on_off(bool(d.get("crouching", false))),
			_on_off(bool(d.get("sprinting", false)))
		]],
		["Cheats", "speed x%.2f  god:%s" % [float(d.get("speed_multiplier", 1.0)), _on_off(bool(d.get("god_mode", false)))]]
	]


func _get_survival_rows() -> Array:
	var survival: Node = null
	if is_instance_valid(_player):
		survival = _player.get_node_or_null("Survival")

	if not is_instance_valid(survival) or not survival.has_method("get_debug_snapshot"):
		return [["Status", "PlayerSurvival not found", COLOR_WARN]]

	var snap: Dictionary = survival.get_debug_snapshot()
	if snap.is_empty():
		return [["Status", "No stats data", COLOR_WARN]]

	var rows: Array = []

	# Status row — drain active + sprint state
	var draining: bool = bool(snap.get("_draining", false))
	var sprinting: bool = bool(snap.get("_sprinting", false))
	var drain_col := COLOR_OK if draining else COLOR_DIM
	var sprint_text := "  sprint:ON" if sprinting else ""
	rows.append(["Status", ("drain:ON" if draining else "drain:OFF") + sprint_text, drain_col])

	# One row per stat
	var stat_order := ["health", "oxygen", "hunger", "thirst", "sanity", "stamina"]
	for stat_name in stat_order:
		if not snap.has(stat_name):
			continue
		var pair: Array = snap[stat_name]
		var current: float = pair[0]
		var maximum: float = pair[1]
		var ratio := current / maximum if maximum > 0.0 else 0.0
		var col: String
		if ratio > 0.5:
			col = COLOR_OK
		elif ratio > 0.25:
			col = COLOR_WARN
		else:
			col = COLOR_BAD
		rows.append([stat_name.capitalize(), "%.1f / %.0f" % [current, maximum], col])
	return rows


func _resolve_player() -> void:
	if is_instance_valid(_player):
		return
	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		_player = players[0]


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_left_column = VBoxContainer.new()
	_left_column.anchor_left = 0.0
	_left_column.anchor_top = 0.0
	_left_column.anchor_right = 0.0
	_left_column.anchor_bottom = 0.0
	_left_column.offset_left = 8.0
	_left_column.offset_top = 8.0
	_left_column.offset_right = 8.0 + PANEL_WIDTH
	_left_column.add_theme_constant_override("separation", PANEL_GAP)
	_left_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_left_column)

	_right_column = VBoxContainer.new()
	_right_column.anchor_left = 1.0
	_right_column.anchor_top = 0.0
	_right_column.anchor_right = 1.0
	_right_column.anchor_bottom = 0.0
	_right_column.offset_left = -8.0 - PANEL_WIDTH
	_right_column.offset_top = 8.0
	_right_column.offset_right = -8.0
	_right_column.add_theme_constant_override("separation", PANEL_GAP)
	_right_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_right_column)

	_panel_labels["performance"] = _create_panel(_left_column)
	_panel_labels["render"] = _create_panel(_left_column)
	_panel_labels["memory"] = _create_panel(_left_column)
	_panel_labels["player"] = _create_panel(_right_column)
	_panel_labels["physics"] = _create_panel(_right_column)
	_panel_labels["world"] = _create_panel(_right_column)
	_panel_labels["survival"] = _create_panel(_right_column)


func _create_panel(parent: VBoxContainer) -> RichTextLabel:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.06, 0.08, 0.88)
	style.set_border_width_all(1)
	style.border_color = Color(0.3, 0.3, 0.35, 0.82)
	style.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)

	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("default_color", Color(0.9, 0.9, 0.95, 1.0))
	label.add_theme_font_size_override("normal_font_size", 12)
	margin.add_child(label)

	parent.add_child(panel)
	return label


func _set_panel_content(key: String, title: String, rows: Array) -> void:
	var label: RichTextLabel = _panel_labels.get(key, null)
	if not is_instance_valid(label):
		return

	var bb := "[b][color=%s]%s[/color][/b]\n" % [COLOR_TITLE, title]
	bb += "[table=2]"
	for row_variant in rows:
		var row: Array = row_variant
		var field := str(row[0]) if row.size() > 0 else ""
		var value := str(row[1]) if row.size() > 1 else ""
		var value_color := str(row[2]) if row.size() > 2 else ""

		bb += "[cell][color=%s]%s[/color][/cell]" % [COLOR_DIM, field]
		if value_color.is_empty():
			bb += "[cell]%s[/cell]" % value
		else:
			bb += "[cell][color=%s]%s[/color][/cell]" % [value_color, value]
	bb += "[/table]"
	label.text = bb

	# Adapt panel minimum height to actual row count so short sections don't leave large empty gaps.
	var panel := label.get_parent().get_parent() as PanelContainer
	if is_instance_valid(panel):
		var estimated_height := 30 + rows.size() * 20
		panel.custom_minimum_size = Vector2(PANEL_WIDTH, estimated_height)


func _fps_color(fps: float) -> String:
	if fps >= 60:
		return COLOR_OK
	if fps >= 30:
		return COLOR_WARN
	return COLOR_BAD


func _frame_time_color(frame_ms: float) -> String:
	if frame_ms <= 16.7:
		return COLOR_OK
	if frame_ms <= 33.3:
		return COLOR_WARN
	return COLOR_BAD


func _cpu_color(cpu_load: float) -> String:
	if cpu_load < 50.0:
		return COLOR_OK
	if cpu_load < 85.0:
		return COLOR_WARN
	return COLOR_BAD


func _draw_color(draws: int) -> String:
	if draws < 1200:
		return COLOR_OK
	if draws < 2500:
		return COLOR_WARN
	return COLOR_BAD


func _mem_color(current: float, system_total: float, local_peak: float) -> String:
	if system_total > 0.0:
		var ratio := current / system_total
		if ratio < 0.15:
			return COLOR_OK
		if ratio < 0.3:
			return COLOR_WARN
		return COLOR_BAD

	# Fallback only when system RAM is unavailable.
	if local_peak <= 0.0:
		return COLOR_DIM
	var local_ratio := current / local_peak
	if local_ratio < 0.65:
		return COLOR_OK
	if local_ratio < 0.9:
		return COLOR_WARN
	return COLOR_BAD


func _get_system_ram_total_bytes() -> float:
	if OS.has_method("get_memory_info"):
		var info_variant: Variant = OS.call("get_memory_info")
		if info_variant is Dictionary:
			var info: Dictionary = info_variant
			if info.has("physical"):
				return float(info["physical"])
			if info.has("total"):
				return float(info["total"])
	return 0.0


func _on_off(v: bool) -> String:
	return "ON" if v else "OFF"


func _fmt_int(v: float) -> String:
	var i := int(v)
	var s := str(i)
	var out := ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3, 3) + out
		s = s.substr(0, s.length() - 3)
	return s + out


func _fmt_bytes(b: float) -> String:
	if b <= 0.0:
		return "0 B"
	if b < 1024.0:
		return "%.0f B" % b
	if b < 1_048_576.0:
		return "%.0f KB" % (b / 1024.0)
	if b < 1_073_741_824.0:
		return "%.1f MB" % (b / 1_048_576.0)
	return "%.2f GB" % (b / 1_073_741_824.0)
