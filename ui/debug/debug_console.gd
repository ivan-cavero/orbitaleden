class_name DebugConsole
extends CanvasLayer
## Debug console toggled with backtick (`).
## Uses _input() at layer=100 to intercept the toggle key before any
## Control child (LineEdit) can receive it.

signal command_executed(cmd: String, args: Array[String])

# ── Constants ────────────────────────────────────────────────────────────────
const MAX_HISTORY := 50
const TOGGLE_KEY := KEY_QUOTELEFT

# ── State ────────────────────────────────────────────────────────────────────
var _open     := false
var _commands: Dictionary     = {}
var _history:  Array[String]  = []
var _history_index := -1
var _toggle_held := false

# ── Node refs ────────────────────────────────────────────────────────────────
@onready var _panel:     PanelContainer  = $Panel
@onready var _output:    RichTextLabel   = $Panel/Margin/VBox/Scroll/Output
@onready var _line_edit: LineEdit        = $Panel/Margin/VBox/InputBar/Input
@onready var _scroll:    ScrollContainer = $Panel/Margin/VBox/Scroll


# ── Lifecycle ────────────────────────────────────────────────────────────────
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel.visible = false
	_line_edit.text_submitted.connect(_on_submitted)
	_line_edit.text_changed.connect(_on_text_changed)
	_register_builtin_commands()
	_print_welcome()


# ── Input ────────────────────────────────────────────────────────────────────
# _input() runs before gui_input on any child Control, so marking the event
# as handled here prevents the backtick from ever reaching the LineEdit.
func _input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key := event as InputEventKey

	# Debounce by full press/release cycle to avoid dead-key double toggles.
	if key.physical_keycode == TOGGLE_KEY and not key.pressed:
		_toggle_held = false
		return

	if _is_toggle_press(key):
		get_viewport().set_input_as_handled()
		_toggle_held = true
		if _open:
			close()
		else:
			open()
		return

	if not key.pressed or key.echo:
		return

	# Navigation keys — only when open and input has focus
	if not _open:
		return
	match key.physical_keycode:
		KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			close()
		KEY_UP:
			get_viewport().set_input_as_handled()
			_history_prev()
		KEY_DOWN:
			get_viewport().set_input_as_handled()
			_history_next()
		KEY_TAB:
			get_viewport().set_input_as_handled()
			_autocomplete()


# ── Public API ───────────────────────────────────────────────────────────────
func open() -> void:
	if _open:
		return
	_open = true
	_panel.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_line_edit.clear()
	_line_edit.grab_focus()
	# Defer a second clear so the backtick unicode character that triggered
	# open() cannot land in the LineEdit after focus is granted.
	_line_edit.clear.call_deferred()


func close() -> void:
	if not _open:
		return
	_open = false
	_panel.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_line_edit.clear()
	_line_edit.release_focus()


func is_open() -> bool:
	return _open


func register_command(cmd_name: String, callable: Callable, description: String, usage: String = "") -> void:
	_commands[cmd_name] = {
		"callable":    callable,
		"description": description,
		"usage":       usage if usage != "" else cmd_name,
	}


# ── Output helpers ───────────────────────────────────────────────────────────
func log_msg(text: String)  -> void: _append(text)
func log_warn(text: String) -> void: _append("[color=#fc0]" + text + "[/color]")
func log_err(text: String)  -> void: _append("[color=#f55]" + text + "[/color]")
func log_ok(text: String)   -> void: _append("[color=#5d5]" + text + "[/color]")

func clear_output() -> void:
	_output.clear()


# ── Internal ─────────────────────────────────────────────────────────────────
func _print_welcome() -> void:
	_append("[color=#555]` to close  |  'help' for commands[/color]")


func _append(text: String) -> void:
	_output.append_text(text + "\n")
	_scroll_to_bottom.call_deferred()


func _scroll_to_bottom() -> void:
	_scroll.scroll_vertical = _scroll.get_v_scroll_bar().max_value as int


func _on_text_changed(new_text: String) -> void:
	var sanitized := _sanitize_toggle_chars(new_text)
	if sanitized != new_text:
		_line_edit.text = sanitized
		_line_edit.caret_column = _line_edit.text.length()


func _on_submitted(text: String) -> void:
	_execute(_sanitize_toggle_chars(text))
	_line_edit.clear()


func _is_toggle_press(key: InputEventKey) -> bool:
	if not key.pressed or key.echo:
		return false
	if key.physical_keycode == TOGGLE_KEY:
		return not _toggle_held
	return false


func _sanitize_toggle_chars(text: String) -> String:
	return text.replace("`", "").replace("º", "").replace("´", "")


func _execute(raw: String) -> void:
	var text := raw.strip_edges()
	if text.is_empty():
		return

	if _history.is_empty() or _history[0] != text:
		_history.push_front(text)
		if _history.size() > MAX_HISTORY:
			_history.resize(MAX_HISTORY)
	_history_index = -1

	_append("[color=#666]> " + text + "[/color]")

	var parts := text.split(" ", false)
	var cmd   := parts[0].to_lower()
	var args: Array[String] = []
	for i in range(1, parts.size()):
		args.append(parts[i])

	if _commands.has(cmd):
		(_commands[cmd] as Dictionary)["callable"].call(args)
		command_executed.emit(cmd, args)
	else:
		log_err("Unknown: '%s'  (type 'help')" % cmd)


func _history_prev() -> void:
	if _history.is_empty():
		return
	_history_index = mini(_history_index + 1, _history.size() - 1)
	_line_edit.text = _history[_history_index]
	_line_edit.caret_column = _line_edit.text.length()


func _history_next() -> void:
	if _history_index <= 0:
		_history_index = -1
		_line_edit.clear()
		return
	_history_index -= 1
	_line_edit.text = _history[_history_index]
	_line_edit.caret_column = _line_edit.text.length()


func _autocomplete() -> void:
	var prefix := _line_edit.text.to_lower().strip_edges()
	if prefix.is_empty():
		return
	var matches: Array[String] = []
	for key: String in _commands:
		if key.begins_with(prefix):
			matches.append(key)
	matches.sort()
	match matches.size():
		0: pass
		1:
			_line_edit.text = matches[0] + " "
			_line_edit.caret_column = _line_edit.text.length()
		_:
			log_msg("  " + "  ".join(matches))


# ── Built-in commands ────────────────────────────────────────────────────────
func _register_builtin_commands() -> void:
	register_command("help",      _cmd_help,      "List all commands",  "help [cmd]")
	register_command("clear",     _cmd_clear,     "Clear output")
	register_command("quit",      _cmd_quit,      "Exit the game")
	register_command("fps",       _cmd_fps,       "Print current FPS")
	register_command("timescale", _cmd_timescale, "Get/set game speed", "timescale [0.1-10]")
	register_command("pause",     _cmd_pause,     "Toggle pause")
	register_command("wireframe", _cmd_wireframe, "Toggle wireframe")


func _cmd_help(args: Array[String]) -> void:
	if args.is_empty():
		var keys: Array = _commands.keys()
		keys.sort()
		for key: String in keys:
			var d: Dictionary = _commands[key]
			log_msg("  %-14s %s" % [key, d["description"]])
	else:
		var cmd := args[0].to_lower()
		if _commands.has(cmd):
			var d: Dictionary = _commands[cmd]
			log_msg(d["description"] as String)
			log_msg("Usage: " + d["usage"] as String)
		else:
			log_err("Unknown: " + cmd)


func _cmd_clear(_a: Array[String])     -> void: clear_output()
func _cmd_quit(_a: Array[String])      -> void: get_tree().quit()
func _cmd_fps(_a: Array[String])       -> void: log_msg("FPS: %d" % Engine.get_frames_per_second())

func _cmd_wireframe(_a: Array[String]) -> void:
	var vp := get_viewport()
	if vp.debug_draw == Viewport.DEBUG_DRAW_WIREFRAME:
		vp.debug_draw = Viewport.DEBUG_DRAW_DISABLED
		log_ok("Wireframe off")
	else:
		vp.debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
		log_ok("Wireframe on")

func _cmd_timescale(args: Array[String]) -> void:
	if args.is_empty():
		log_msg("Timescale: %.2f" % Engine.time_scale)
		return
	Engine.time_scale = clampf(args[0].to_float(), 0.1, 10.0)
	log_ok("Timescale: %.2f" % Engine.time_scale)

func _cmd_pause(_a: Array[String]) -> void:
	get_tree().paused = not get_tree().paused
	log_ok("Game %s" % ("paused" if get_tree().paused else "resumed"))
