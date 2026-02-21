extends Node
## Debug singleton. Autoloaded as "Debug".
## Provides global logging API and registers extra console commands.
## Keep this thin — no game logic here.

# ── Node refs (set by _ready) ─────────────────────────────────────────────
var console: DebugConsole
var overlay: DebugOverlay

# ── Scenes ───────────────────────────────────────────────────────────────────
const CONSOLE_SCENE: PackedScene = preload("res://ui/debug/debug_console.tscn")
const OVERLAY_SCENE: PackedScene = preload("res://ui/debug/debug_overlay.tscn")


# ── Lifecycle ────────────────────────────────────────────────────────────────
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	console = CONSOLE_SCENE.instantiate()
	overlay = OVERLAY_SCENE.instantiate()
	add_child(console)
	add_child(overlay)

	_register_commands()


# ── Logging API ───────────────────────────────────────────────────────────────
func info(msg: String) -> void:
	if is_instance_valid(console):
		console.log_msg(msg)
	print(msg)


func warn(msg: String) -> void:
	if is_instance_valid(console):
		console.log_warn(msg)
	push_warning(msg)


func error(msg: String) -> void:
	if is_instance_valid(console):
		console.log_err(msg)
	push_error(msg)


func ok(msg: String) -> void:
	if is_instance_valid(console):
		console.log_ok(msg)
	print(msg)


# ── UI Blocking Check ────────────────────────────────────────────────────────

## Returns true when any blocking UI is open (console, inventory, etc.).
## Used by player controller and interaction to suppress gameplay input.
func is_ui_blocking() -> bool:
	if is_instance_valid(console) and console.is_open():
		return true
	var inventory_nodes := get_tree().get_nodes_in_group("inventory_ui")
	for node in inventory_nodes:
		if node.has_method("is_open") and node.is_open():
			return true
	return false


# ── Extra commands ────────────────────────────────────────────────────────────
func _register_commands() -> void:
	console.register_command("overlay",   _cmd_overlay,   "Toggle F3 debug overlay")
	console.register_command("collision", _cmd_collision, "Toggle collision debug shapes")


func _cmd_overlay(_args: Array[String]) -> void:
	if overlay.is_open():
		overlay.close()
	else:
		overlay.open()


func _cmd_collision(_args: Array[String]) -> void:
	var tree := get_tree()
	tree.debug_collisions_hint = not tree.debug_collisions_hint
	ok("Collision shapes: %s  (reload scene to apply)" % ("on" if tree.debug_collisions_hint else "off"))
