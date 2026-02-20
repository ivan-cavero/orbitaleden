class_name PlayerInteraction
extends Node
## Handles player interaction with Interactable objects.
##
## Attached to the Player, this component:
## - Detects interactables via raycast
## - Applies highlight effect when looking at them
## - Handles input for interaction

# ─────────────────────────────────────────────────────────────────────────────
# Constants
# ─────────────────────────────────────────────────────────────────────────────

const InteractableScript := preload("res://entities/interactable/interactable.gd")

# ─────────────────────────────────────────────────────────────────────────────
# Signals
# ─────────────────────────────────────────────────────────────────────────────

## Emitted when the targeted interactable changes (null if none).
signal target_changed(interactable: Node)

# ─────────────────────────────────────────────────────────────────────────────
# Exports
# ─────────────────────────────────────────────────────────────────────────────

@export var interaction_range: float = 3.0
@export var highlight_emission_strength: float = 0.4

# ─────────────────────────────────────────────────────────────────────────────
# Public Variables
# ─────────────────────────────────────────────────────────────────────────────

## Currently targeted interactable (read-only externally).
var current_target: Node = null

# ─────────────────────────────────────────────────────────────────────────────
# Private Variables
# ─────────────────────────────────────────────────────────────────────────────

## Stores original materials for highlight restoration.
## Format: [{mesh: MeshInstance3D, surface_idx: int, original_material: Material}]
var _highlighted_data: Array[Dictionary] = []

# ─────────────────────────────────────────────────────────────────────────────
# Onready
# ─────────────────────────────────────────────────────────────────────────────

@onready var _player: PlayerController = get_parent()
@onready var _raycast: RayCast3D = _player.get_node("Head/RayCast3D")

# ─────────────────────────────────────────────────────────────────────────────
# Lifecycle
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	_configure_raycast()


func _physics_process(_delta: float) -> void:
	_update_target()


func _input(event: InputEvent) -> void:
	if _is_ui_blocking():
		return
	if event.is_action_pressed("interact"):
		_try_interact()


func _is_ui_blocking() -> bool:
	if is_instance_valid(Debug.console) and Debug.console.is_open():
		return true
	var inv_nodes := get_tree().get_nodes_in_group("inventory_ui")
	for node in inv_nodes:
		if node.has_method("is_open") and node.is_open():
			return true
	return false

# ─────────────────────────────────────────────────────────────────────────────
# Setup
# ─────────────────────────────────────────────────────────────────────────────

func _configure_raycast() -> void:
	_raycast.target_position = Vector3(0, 0, -interaction_range)
	_raycast.enabled = true
	_raycast.collide_with_areas = true
	_raycast.collide_with_bodies = true

# ─────────────────────────────────────────────────────────────────────────────
# Target Detection
# ─────────────────────────────────────────────────────────────────────────────

func _update_target() -> void:
	# Check if current target was destroyed
	if current_target and not is_instance_valid(current_target):
		_highlighted_data.clear()
		current_target = null
		target_changed.emit(null)
		return
	
	var new_target := _detect_interactable()
	
	if new_target != current_target:
		_set_target(new_target)


func _detect_interactable() -> Node:
	if not _raycast.is_colliding():
		return null
	
	var collider := _raycast.get_collider()
	if not collider or not collider.is_in_group("interactable"):
		return null
	
	return _find_interactable_component(collider)


func _find_interactable_component(node: Node) -> Node:
	for child in node.get_children():
		if _is_interactable_script(child):
			return child
	return null


func _is_interactable_script(node: Node) -> bool:
	var script: Script = node.get_script()
	while script:
		if script == InteractableScript:
			return true
		script = script.get_base_script()
	return false


func _set_target(new_target: Node) -> void:
	_remove_highlight()
	current_target = new_target
	
	if current_target and current_target.show_highlight:
		_apply_highlight()
	
	target_changed.emit(current_target)

# ─────────────────────────────────────────────────────────────────────────────
# Interaction
# ─────────────────────────────────────────────────────────────────────────────

func _try_interact() -> void:
	if not is_instance_valid(current_target):
		current_target = null
		return
	
	if not current_target.enabled:
		return
	
	# Interact and immediately clear target (it will be destroyed)
	current_target.interact(_player)
	_highlighted_data.clear()
	current_target = null
	target_changed.emit(null)

# ─────────────────────────────────────────────────────────────────────────────
# Highlight System
# ─────────────────────────────────────────────────────────────────────────────

func _apply_highlight() -> void:
	var parent := current_target.get_parent()
	if not parent:
		return
	
	var tint_color: Color = current_target.highlight_color
	_highlighted_data.clear()
	_apply_highlight_recursive(parent, tint_color)


func _apply_highlight_recursive(node: Node, tint_color: Color) -> void:
	if node is MeshInstance3D:
		_highlight_mesh(node as MeshInstance3D, tint_color)
	
	for child in node.get_children():
		_apply_highlight_recursive(child, tint_color)


func _highlight_mesh(mesh: MeshInstance3D, tint_color: Color) -> void:
	if not mesh.mesh:
		return
	
	var surface_count := mesh.mesh.get_surface_count()
	
	for i in range(surface_count):
		var original := mesh.get_surface_override_material(i)
		var source_mat := original if original else mesh.mesh.surface_get_material(i)
		
		# Create highlighted material
		var highlighted := _create_highlighted_material(source_mat, tint_color)
		
		# Store original and apply highlight
		_highlighted_data.append({
			"mesh": mesh,
			"surface_idx": i,
			"original_material": original
		})
		mesh.set_surface_override_material(i, highlighted)


func _create_highlighted_material(source: Material, tint_color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	
	if source and source is StandardMaterial3D:
		var src := source as StandardMaterial3D
		mat.albedo_color = src.albedo_color
	else:
		mat.albedo_color = Color(0.5, 0.5, 0.5)
	
	mat.emission_enabled = true
	mat.emission = tint_color
	mat.emission_energy_multiplier = highlight_emission_strength
	
	return mat


func _remove_highlight() -> void:
	for data in _highlighted_data:
		var mesh = data["mesh"]  # No type hint to avoid freed instance errors
		if is_instance_valid(mesh):
			mesh.set_surface_override_material(data["surface_idx"], data["original_material"])
	
	_highlighted_data.clear()

# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

## Returns the interaction prompt text for the current target.
func get_prompt_text() -> String:
	if current_target and current_target.enabled:
		return "[E] " + current_target.get_interaction_text()
	return ""
