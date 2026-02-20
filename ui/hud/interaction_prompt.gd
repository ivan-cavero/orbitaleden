class_name InteractionPrompt
extends CanvasLayer
## UI component that displays the interaction prompt.
##
## Shows "[E] Action" text when the player is looking at an interactable.
## Updates in real-time to reflect state changes (e.g., toggle switches).

# ─────────────────────────────────────────────────────────────────────────────
# Onready
# ─────────────────────────────────────────────────────────────────────────────

@onready var _panel: PanelContainer = $CenterContainer/Panel
@onready var _label: Label = $CenterContainer/Panel/MarginContainer/Label

# ─────────────────────────────────────────────────────────────────────────────
# Private Variables
# ─────────────────────────────────────────────────────────────────────────────

var _player_interaction: PlayerInteraction = null

# ─────────────────────────────────────────────────────────────────────────────
# Lifecycle
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	_panel.visible = false
	_setup_panel_style()


func _process(_delta: float) -> void:
	_update_prompt()

# ─────────────────────────────────────────────────────────────────────────────
# Setup
# ─────────────────────────────────────────────────────────────────────────────

func _setup_panel_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.6)
	style.set_corner_radius_all(4)
	_panel.add_theme_stylebox_override("panel", style)


## Connect to a PlayerInteraction component.
func setup(player_interaction: PlayerInteraction) -> void:
	_player_interaction = player_interaction

# ─────────────────────────────────────────────────────────────────────────────
# Update
# ─────────────────────────────────────────────────────────────────────────────

func _update_prompt() -> void:
	if not _player_interaction:
		_panel.visible = false
		return
	
	# Get target and validate it's not freed
	var target = _player_interaction.current_target
	
	if not is_instance_valid(target):
		_panel.visible = false
		return
	
	if not target.enabled:
		_panel.visible = false
		return
	
	var prompt_text := _player_interaction.get_prompt_text()
	
	if prompt_text.is_empty():
		_panel.visible = false
		return
	
	_label.text = prompt_text
	_panel.visible = true


func _is_valid_target(target) -> bool:
	if target == null:
		return false
	if not is_instance_valid(target):
		return false
	if target.is_queued_for_deletion():
		return false
	return target.enabled
