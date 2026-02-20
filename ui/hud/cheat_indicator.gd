extends CanvasLayer
## Cheat indicator overlay.
## Displays active cheat modes (noclip, fly, god, speed) in top-right corner.

# === Private ===
var _active_cheats: Dictionary = {}   # cheat_name -> display_string

# === Onready ===
@onready var _label: Label = $Panel/Label


# ── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 99
	hide()


# ── Public API ───────────────────────────────────────────────────────────────

func set_cheat(cheat_name: String, active: bool, display: String = "") -> void:
	if active:
		_active_cheats[cheat_name] = display if display != "" else cheat_name.to_upper()
	else:
		_active_cheats.erase(cheat_name)
	_refresh()


func _refresh() -> void:
	if _active_cheats.is_empty():
		hide()
		return
	var lines: Array[String] = []
	for key: String in _active_cheats:
		lines.append(_active_cheats[key])
	_label.text = "\n".join(lines)
	show()
