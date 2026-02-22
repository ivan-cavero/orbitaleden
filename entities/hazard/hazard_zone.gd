@tool
class_name HazardZone
extends Area3D
## Damage-over-time zone.
## Configure damage_type and damage_per_second in the Inspector.
## Resize the zone by selecting the ZoneShape child and editing its Shape3D.

@export_group("Hazard")
@export_enum("physical", "fire", "electric", "toxic", "suffocation") \
		var damage_type: String = "fire"
@export_range(0.0, 1000.0, 0.5) var damage_per_second: float = 10.0

@export_group("Editor Preview")
@export var editor_preview_enabled: bool = true
@export_range(0.05, 1.0, 0.05) var editor_preview_alpha: float = 0.35

const DAMAGE_TICK_INTERVAL: float = 0.25

@onready var _zone_shape: CollisionShape3D = get_node_or_null("ZoneShape")
@onready var _zone_mesh: MeshInstance3D = get_node_or_null("ZoneMesh")

var _players_inside: Dictionary = {}
var _editor_last_shape: Shape3D
var _editor_last_type: String = ""


func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(true)
		set_physics_process(false)
		_connect_shape_changed()
		_update_editor_preview()
		return

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	monitoring = true
	monitorable = false
	set_process(false)
	set_physics_process(true)


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	_editor_poll_preview()


func _physics_process(delta: float) -> void:
	if _players_inside.is_empty():
		return

	for body: Node in _players_inside.keys().duplicate():
		if not is_instance_valid(body):
			_players_inside.erase(body)
			continue

		var body_timer: float = _players_inside[body] + delta
		while body_timer >= DAMAGE_TICK_INTERVAL:
			body_timer -= DAMAGE_TICK_INTERVAL
			var tick_damage: float = damage_per_second * DAMAGE_TICK_INTERVAL
			if body.has_method("take_damage"):
				# Hazard DoT bypasses combat i-frames so DPS matches configuration.
				body.take_damage(tick_damage, damage_type, true)

		_players_inside[body] = body_timer


func _on_body_entered(body: Node3D) -> void:
	if _is_damage_receiver(body):
		_players_inside[body] = 0.0


func _on_body_exited(body: Node3D) -> void:
	if _players_inside.has(body):
		_players_inside.erase(body)


func _is_damage_receiver(body: Node) -> bool:
	return body.has_method("take_damage")


func _connect_shape_changed() -> void:
	if not is_instance_valid(_zone_shape):
		return
	if _zone_shape.shape != null and not _zone_shape.shape.changed.is_connected(_update_editor_preview):
		_zone_shape.shape.changed.connect(_update_editor_preview)


func _editor_poll_preview() -> void:
	if not editor_preview_enabled:
		if is_instance_valid(_zone_mesh):
			_zone_mesh.material_override = null
		return

	if not is_instance_valid(_zone_shape) or not is_instance_valid(_zone_mesh):
		return

	if _editor_last_shape != _zone_shape.shape or _editor_last_type != damage_type:
		_connect_shape_changed()
		_update_editor_preview()


func _update_editor_preview() -> void:
	if not Engine.is_editor_hint():
		return
	if not editor_preview_enabled:
		return
	if not is_instance_valid(_zone_shape) or not is_instance_valid(_zone_mesh):
		return

	_editor_last_shape = _zone_shape.shape
	_editor_last_type = damage_type

	if _zone_shape.shape == null:
		return

	var shape := _zone_shape.shape
	var preview_mesh: Mesh = _build_mesh_for_shape(shape)
	if preview_mesh != null:
		_zone_mesh.mesh = preview_mesh

	_zone_mesh.visible = true
	_zone_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_zone_mesh.material_override = _build_editor_material()


func _build_mesh_for_shape(shape: Shape3D) -> Mesh:
	if shape is BoxShape3D:
		var box_shape := shape as BoxShape3D
		var box_mesh := BoxMesh.new()
		box_mesh.size = box_shape.size
		return box_mesh

	if shape is SphereShape3D:
		var sphere_shape := shape as SphereShape3D
		var sphere_mesh := SphereMesh.new()
		sphere_mesh.radius = sphere_shape.radius
		sphere_mesh.height = sphere_shape.radius * 2.0
		return sphere_mesh

	if shape is CylinderShape3D:
		var cylinder_shape := shape as CylinderShape3D
		var cylinder_mesh := CylinderMesh.new()
		cylinder_mesh.top_radius = cylinder_shape.radius
		cylinder_mesh.bottom_radius = cylinder_shape.radius
		cylinder_mesh.height = cylinder_shape.height
		return cylinder_mesh

	if shape is CapsuleShape3D:
		var capsule_shape := shape as CapsuleShape3D
		var capsule_mesh := CapsuleMesh.new()
		capsule_mesh.radius = capsule_shape.radius
		capsule_mesh.height = capsule_shape.height
		return capsule_mesh

	# Custom shape fallback: keep current mesh, just apply preview material.
	return null


func _build_editor_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	var base_color := _get_hazard_color()
	base_color.a = editor_preview_alpha
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = base_color
	mat.emission_enabled = true
	mat.emission = _get_hazard_color() * 0.35
	return mat


func _get_hazard_color() -> Color:
	match damage_type:
		"physical":
			return Color(0.9, 0.2, 0.2)
		"fire":
			return Color(1.0, 0.45, 0.0)
		"electric":
			return Color(0.9, 0.95, 0.2)
		"toxic":
			return Color(0.15, 0.85, 0.2)
		"suffocation":
			return Color(0.35, 0.65, 1.0)
		_:
			return Color(0.8, 0.8, 0.8)
