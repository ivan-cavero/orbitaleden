class_name Interactable
extends Node
## Component that makes any parent Node3D interactable.
##
## Add as a child to any StaticBody3D/RigidBody3D/Area3D to make it interactable.
## Configure the interaction type and visual feedback from the editor inspector.
##
## Usage:
##   1. Add this node as child of a physics body
##   2. Set interaction_type (SIMPLE, ACTIVATE, or TOGGLE)
##   3. Configure texts and colors as needed
##   4. Connect to signals for custom behavior

# ─────────────────────────────────────────────────────────────────────────────
# Signals
# ─────────────────────────────────────────────────────────────────────────────

## Emitted on any interaction (SIMPLE type)
signal interacted(player: Node)

## Emitted when activated (ACTIVATE and TOGGLE types)
signal activated(player: Node)

## Emitted when deactivated (TOGGLE type only)
signal deactivated(player: Node)

## Emitted when state changes (TOGGLE type), includes new state
signal state_changed(is_active: bool, player: Node)

# ─────────────────────────────────────────────────────────────────────────────
# Enums
# ─────────────────────────────────────────────────────────────────────────────

enum Type {
	SIMPLE,    ## Triggers signal on interact, no state management
	ACTIVATE,  ## Can be activated (optionally single-use)
	TOGGLE,    ## Can be toggled on/off repeatedly
}

# ─────────────────────────────────────────────────────────────────────────────
# Exports
# ─────────────────────────────────────────────────────────────────────────────

@export_group("Interaction")
@export var interaction_type: Type = Type.SIMPLE
@export var enabled: bool = true
## Text for SIMPLE type
@export var interaction_text: String = "Interact"
## Text when inactive (ACTIVATE/TOGGLE)
@export var text_activate: String = "Activate"
## Text when active (TOGGLE only)
@export var text_deactivate: String = "Deactivate"

@export_group("State (ACTIVATE/TOGGLE)")
@export var is_active: bool = false
## If true, ACTIVATE type disables after first use
@export var single_use: bool = true

@export_group("Highlight")
@export var show_highlight: bool = true
@export var highlight_color: Color = Color(1.0, 0.8, 0.2, 1.0)

@export_group("State Colors")
## Enable color change based on active state
@export var use_state_colors: bool = false
@export var color_inactive: Color = Color(0.4, 0.2, 0.2, 1.0)
@export var color_active: Color = Color(0.2, 0.8, 0.2, 1.0)

# ─────────────────────────────────────────────────────────────────────────────
# Private Variables
# ─────────────────────────────────────────────────────────────────────────────

var _mesh_instance: MeshInstance3D = null
var _state_material: StandardMaterial3D = null

# ─────────────────────────────────────────────────────────────────────────────
# Lifecycle
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	_register_parent()
	_setup_state_colors()


func _register_parent() -> void:
	var parent := get_parent()
	if parent:
		parent.add_to_group("interactable")


func _setup_state_colors() -> void:
	if not use_state_colors:
		return
	
	_mesh_instance = get_parent().get_node_or_null("MeshInstance3D")
	if _mesh_instance:
		_state_material = StandardMaterial3D.new()
		_mesh_instance.material_override = _state_material
		_update_state_visuals()

# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

## Called by PlayerInteraction when player presses interact key.
func interact(player: Node) -> void:
	if not enabled:
		return
	
	match interaction_type:
		Type.SIMPLE:
			_handle_simple(player)
		Type.ACTIVATE:
			_handle_activate(player)
		Type.TOGGLE:
			_handle_toggle(player)


## Returns the prompt text based on current state.
func get_interaction_text() -> String:
	match interaction_type:
		Type.SIMPLE:
			return interaction_text
		Type.ACTIVATE:
			return text_activate if not is_active else ""
		Type.TOGGLE:
			return text_deactivate if is_active else text_activate
	return interaction_text


## Programmatically set the active state (does not emit signals).
func set_active(value: bool) -> void:
	is_active = value
	_update_state_visuals()


## Enable or disable interactions.
func set_enabled(value: bool) -> void:
	enabled = value

# ─────────────────────────────────────────────────────────────────────────────
# Interaction Handlers
# ─────────────────────────────────────────────────────────────────────────────

func _handle_simple(player: Node) -> void:
	interacted.emit(player)
	_on_interact(player)


func _handle_activate(player: Node) -> void:
	if is_active:
		return
	
	is_active = true
	_update_state_visuals()
	activated.emit(player)
	state_changed.emit(is_active, player)
	_on_activated(player)
	
	if single_use:
		enabled = false


func _handle_toggle(player: Node) -> void:
	is_active = not is_active
	_update_state_visuals()
	state_changed.emit(is_active, player)
	
	if is_active:
		activated.emit(player)
		_on_activated(player)
	else:
		deactivated.emit(player)
		_on_deactivated(player)

# ─────────────────────────────────────────────────────────────────────────────
# Visual Updates
# ─────────────────────────────────────────────────────────────────────────────

func _update_state_visuals() -> void:
	if not _state_material:
		return
	
	var color := color_active if is_active else color_inactive
	_state_material.albedo_color = color
	_state_material.emission_enabled = is_active
	
	if is_active:
		_state_material.emission = color
		_state_material.emission_energy_multiplier = 0.5

# ─────────────────────────────────────────────────────────────────────────────
# Virtual Methods (override in subclasses)
# ─────────────────────────────────────────────────────────────────────────────

## Override for custom SIMPLE interaction behavior.
func _on_interact(_player: Node) -> void:
	pass


## Override for custom activation behavior.
func _on_activated(_player: Node) -> void:
	pass


## Override for custom deactivation behavior.
func _on_deactivated(_player: Node) -> void:
	pass
