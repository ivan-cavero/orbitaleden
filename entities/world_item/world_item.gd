class_name WorldItem
extends RigidBody3D
## A pickable item that exists in the game world.
##
## WorldItems display an ItemDefinition's mesh and can be interacted with 
## to pick up the item. They can optionally be pushed by players/entities.
##
## Usage:
##   - Call setup() with an ItemDefinition and quantity after instantiation
##   - Or set item_definition and quantity exports in editor for pre-placed items

# ─────────────────────────────────────────────────────────────────────────────
# Signals
# ─────────────────────────────────────────────────────────────────────────────

## Emitted when the item is picked up. Passes the item definition and quantity.
signal picked_up(item: Resource, quantity: int, player: Node)

# ─────────────────────────────────────────────────────────────────────────────
# Exports
# ─────────────────────────────────────────────────────────────────────────────

@export_group("Item")
## The item this world item represents
@export var item_definition: Resource:
	set(value):
		item_definition = value
		if is_inside_tree():
			_update_visuals()

## How many of this item
@export_range(1, 999) var quantity: int = 1:
	set(value):
		quantity = value
		if is_inside_tree():
			_update_visuals()

@export_group("Physics")
## If true, players and entities can push this item
@export var pushable: bool = true:
	set(value):
		pushable = value
		if is_inside_tree():
			_update_physics_mode()

## Mass override (0 = use item weight, minimum 1.0)
@export var mass_override: float = 0.0

## Linear damping to slow down movement
@export var linear_damping_value: float = 2.0

## Angular damping to reduce spinning
@export var angular_damping_value: float = 3.0

@export_group("Visuals")
## Scale applied to the mesh
@export var mesh_scale: float = 1.0

# ─────────────────────────────────────────────────────────────────────────────
# Node References
# ─────────────────────────────────────────────────────────────────────────────

@onready var _mesh_pivot: Node3D = $MeshPivot
@onready var _mesh_instance: MeshInstance3D = $MeshPivot/MeshInstance3D
@onready var _collision: CollisionShape3D = $CollisionShape3D
@onready var _interactable: Node = $Interactable

# ─────────────────────────────────────────────────────────────────────────────
# Lifecycle
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	_update_visuals()
	_update_physics_mode()
	_connect_signals()

# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

## Initialize the world item with an item definition and quantity.
## Call this after instantiating the scene.
func setup(p_item: Resource, p_quantity: int = 1) -> void:
	item_definition = p_item
	quantity = p_quantity


## Try to pick up this item. Returns true if successful.
func try_pickup(player: Node) -> bool:
	if not is_instance_valid(item_definition):
		Debug.error("WorldItem: Cannot pickup - no item definition")
		return false
	
	# Emit signal for inventory system to handle
	picked_up.emit(item_definition, quantity, player)
	
	Debug.ok("Picked up %dx %s" % [quantity, item_definition.display_name])
	queue_free()
	return true

# ─────────────────────────────────────────────────────────────────────────────
# Setup Methods
# ─────────────────────────────────────────────────────────────────────────────

func _update_visuals() -> void:
	if not is_instance_valid(_mesh_instance):
		return
	
	if not is_instance_valid(item_definition):
		_mesh_instance.visible = false
		return
	
	# Create a simple colored box mesh
	var box := BoxMesh.new()
	box.size = Vector3(0.2, 0.2, 0.2)
	_mesh_instance.mesh = box
	
	# Apply color from item definition
	var material := StandardMaterial3D.new()
	material.albedo_color = item_definition.color
	material.emission_enabled = true
	material.emission = item_definition.color * 0.3
	material.emission_energy_multiplier = 0.5
	_mesh_instance.material_override = material
	
	# Apply scale
	_mesh_pivot.scale = Vector3.ONE * mesh_scale
	_mesh_instance.visible = true
	
	# Update collision shape to match
	_update_collision_shape()
	
	# Update interactable text
	_update_interaction_text()


func _update_collision_shape() -> void:
	if not is_instance_valid(_collision):
		return
	
	var box := BoxShape3D.new()
	box.size = Vector3(0.2, 0.2, 0.2) * mesh_scale
	_collision.shape = box


func _update_interaction_text() -> void:
	if not _interactable or not is_instance_valid(item_definition):
		return
	
	var item_name: String = item_definition.display_name
	if quantity > 1:
		_interactable.interaction_text = "Pick up %s (x%d)" % [item_name, quantity]
	else:
		_interactable.interaction_text = "Pick up %s" % item_name


func _update_physics_mode() -> void:
	if pushable:
		# Dynamic physics - can be pushed
		freeze = false
		# Set mass (minimum 1.0 for reasonable physics)
		if mass_override > 0:
			mass = mass_override
		elif is_instance_valid(item_definition):
			mass = maxf(item_definition.weight * quantity, 1.0)
		else:
			mass = 1.0
		# Apply damping to prevent sliding/spinning
		linear_damp = linear_damping_value
		angular_damp = angular_damping_value
	else:
		# Static - cannot be pushed
		freeze = true
		freeze_mode = RigidBody3D.FREEZE_MODE_STATIC


func _connect_signals() -> void:
	if _interactable:
		_interactable.interacted.connect(_on_interacted)

# ─────────────────────────────────────────────────────────────────────────────
# Signal Handlers
# ─────────────────────────────────────────────────────────────────────────────

func _on_interacted(player: Node) -> void:
	try_pickup(player)
