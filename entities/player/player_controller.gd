class_name PlayerController
extends CharacterBody3D
## First-person player controller.
## Handles mouse look, WASD movement, sprint, crouch, jump,
## head bob, and noclip/fly cheat modes.

# === Signals ===
signal cheat_mode_changed(mode: String, active: bool)

# === Enums ===
enum MoveMode { NORMAL, FLY, NOCLIP }

# === Exports ===
@export_group("Mouse Look")
@export var mouse_sensitivity: float = 0.3
@export var pitch_min: float = -89.0
@export var pitch_max: float = 89.0

@export_group("Movement")
@export var walk_speed: float = 5.0
@export var sprint_multiplier: float = 1.5
@export var crouch_multiplier: float = 0.5
@export var noclip_speed: float = 10.0
@export var acceleration: float = 12.0
@export var deceleration: float = 16.0
@export var jump_velocity: float = 5.0
@export var gravity_scale: float = 1.0

@export_group("Crouch")
@export var stand_height: float = 1.8
@export var crouch_height: float = 1.0
@export var eye_height_stand: float = 1.6
@export var eye_height_crouch: float = 0.8
@export var crouch_speed: float = 8.0

@export_group("Head Bob")
@export var bob_enabled: bool = true
@export var bob_frequency: float = 2.0
@export var bob_amplitude: float = 0.02

@export_group("Physics Interaction")
## Force applied when pushing RigidBody3D objects
@export var push_force: float = 0.8
## Maximum velocity a pushed object can have
@export var max_push_velocity: float = 3.0

# === Constants ===
const GRAVITY: float = 9.8

# === Public ===
var move_mode: MoveMode = MoveMode.NORMAL
var speed_multiplier: float = 1.0   # for `speed` cheat
var god_mode: bool = false

# === Private ===
var _pitch: float = 0.0
var _bob_time: float = 0.0
var _is_crouching: bool = false
var _current_eye_y: float = 1.6
var _spawn_position: Vector3 = Vector3.ZERO
var _spawn_rotation: float = 0.0

# === Onready ===
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var ray_interact: RayCast3D = $Head/RayCast3D
@onready var col_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D


# ── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")
	_spawn_position = global_position
	_spawn_rotation = rotation.y
	_current_eye_y = eye_height_stand
	head.position.y = _current_eye_y
	Debug.info("Player ready at %s" % global_position)


func _input(event: InputEvent) -> void:
	if Debug.is_ui_blocking():
		return

	# Release mouse on Escape
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and key_event.physical_keycode == KEY_ESCAPE:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				return

	# Recapture mouse on click when not captured
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			return

	# Mouse look (only when captured)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var motion := event as InputEventMouseMotion
		rotation.y -= deg_to_rad(motion.relative.x * mouse_sensitivity)
		_pitch -= motion.relative.y * mouse_sensitivity
		_pitch = clamp(_pitch, pitch_min, pitch_max)
		head.rotation.x = deg_to_rad(_pitch)


func _physics_process(delta: float) -> void:
	if Debug.is_ui_blocking():
		# Still apply gravity so the player doesn't float
		if move_mode == MoveMode.NORMAL and not is_on_floor():
			velocity.y -= GRAVITY * gravity_scale * delta
			move_and_slide()
		return

	match move_mode:
		MoveMode.NORMAL:
			_process_normal(delta)
		MoveMode.FLY:
			_process_fly(delta)
		MoveMode.NOCLIP:
			_process_noclip(delta)

	_process_crouch(delta)
	_process_head_bob(delta)


# ── Movement modes ────────────────────────────────────────────────────────────

func _process_normal(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * gravity_scale * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var current_speed := _get_current_speed()
	var wish_dir := _get_wish_dir()

	if wish_dir.length_squared() > 0.0:
		velocity.x = move_toward(velocity.x, wish_dir.x * current_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, wish_dir.z * current_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, deceleration * delta)

	move_and_slide()
	_push_rigid_bodies()


func _process_fly(delta: float) -> void:
	var current_speed := noclip_speed * speed_multiplier
	var wish_dir := _get_wish_dir_3d()

	if wish_dir.length_squared() > 0.0:
		velocity = velocity.move_toward(wish_dir * current_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector3.ZERO, deceleration * delta)

	move_and_slide()


func _process_noclip(delta: float) -> void:
	var current_speed := noclip_speed * speed_multiplier
	var wish_dir := _get_wish_dir_3d()

	# In noclip we set position directly to pass through geometry
	if wish_dir.length_squared() > 0.0:
		velocity = wish_dir * current_speed
	else:
		velocity = Vector3.ZERO

	global_position += velocity * delta


# ── Helpers ───────────────────────────────────────────────────────────────────

func _get_current_speed() -> float:
	var s := walk_speed * speed_multiplier
	if _is_crouching:
		s *= crouch_multiplier
	elif Input.is_action_pressed("sprint"):
		s *= sprint_multiplier
	return s


func _get_wish_dir() -> Vector3:
	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_forward", "move_backward")
	)
	if input_dir.length_squared() == 0.0:
		return Vector3.ZERO
	var dir := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	return dir


func _get_wish_dir_3d() -> Vector3:
	# For fly/noclip: includes vertical movement relative to camera pitch
	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_forward", "move_backward")
	)
	var up_down := Input.get_axis("crouch", "jump")

	var forward := -head.global_transform.basis.z
	var right := head.global_transform.basis.x
	var dir := (right * input_dir.x + forward * (-input_dir.y) + Vector3.UP * up_down).normalized()
	return dir


func _process_crouch(delta: float) -> void:
	_is_crouching = Input.is_action_pressed("crouch") and move_mode == MoveMode.NORMAL

	var target_eye_y := eye_height_crouch if _is_crouching else eye_height_stand
	_current_eye_y = move_toward(_current_eye_y, target_eye_y, crouch_speed * delta)
	head.position.y = _current_eye_y

	# Smoothly adjust capsule height via scale (simpler than resizing shape)
	var target_capsule_scale := (crouch_height / stand_height) if _is_crouching else 1.0
	col_shape.scale.y = move_toward(col_shape.scale.y, target_capsule_scale, crouch_speed * delta)


func _process_head_bob(delta: float) -> void:
	if not bob_enabled or move_mode != MoveMode.NORMAL:
		# Reset bob
		camera.position.y = move_toward(camera.position.y, 0.0, 4.0 * delta)
		return

	var is_moving := velocity.length_squared() > 0.1 and is_on_floor()
	if is_moving:
		_bob_time += delta * bob_frequency * TAU
		camera.position.y = sin(_bob_time) * bob_amplitude
	else:
		_bob_time = 0.0
		camera.position.y = move_toward(camera.position.y, 0.0, 4.0 * delta)


# ── Public API (called by cheat commands) ────────────────────────────────────

func set_noclip(active: bool) -> void:
	if active:
		move_mode = MoveMode.NOCLIP
		velocity = Vector3.ZERO
	else:
		move_mode = MoveMode.NORMAL
		velocity = Vector3.ZERO
	cheat_mode_changed.emit("noclip", active)


func set_fly(active: bool) -> void:
	if active:
		move_mode = MoveMode.FLY
		velocity = Vector3.ZERO
	else:
		move_mode = MoveMode.NORMAL
		velocity = Vector3.ZERO
	cheat_mode_changed.emit("fly", active)


func respawn() -> void:
	global_position = _spawn_position
	rotation.y = _spawn_rotation
	velocity = Vector3.ZERO
	Debug.ok("Respawned at %s" % _spawn_position)


func set_spawn(pos: Vector3, yaw: float = 0.0) -> void:
	_spawn_position = pos
	_spawn_rotation = yaw


func get_debug_snapshot() -> Dictionary:
	var look_forward := -head.global_transform.basis.z
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var mode_name := "NORMAL"
	match move_mode:
		MoveMode.FLY:
			mode_name = "FLY"
		MoveMode.NOCLIP:
			mode_name = "NOCLIP"

	return {
		"position": global_position,
		"velocity": velocity,
		"horizontal_speed": horizontal_speed,
		"look_forward": look_forward,
		"yaw_deg": rad_to_deg(rotation.y),
		"pitch_deg": _pitch,
		"on_floor": is_on_floor(),
		"crouching": _is_crouching,
		"sprinting": Input.is_action_pressed("sprint") and move_mode == MoveMode.NORMAL and not _is_crouching,
		"mode": mode_name,
		"speed_multiplier": speed_multiplier,
		"god_mode": god_mode,
	}


func _push_rigid_bodies() -> void:
	# Push any RigidBody3D we collided with
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		
		if collider is RigidBody3D:
			var rigid := collider as RigidBody3D
			# Check if it's frozen (not pushable)
			if rigid.freeze:
				continue
			
			# Don't push if already moving fast enough
			var horizontal_vel := Vector2(rigid.linear_velocity.x, rigid.linear_velocity.z)
			if horizontal_vel.length() >= max_push_velocity:
				continue
			
			# Apply force in the direction we're moving
			var push_dir := -collision.get_normal()
			push_dir.y = 0  # Only push horizontally
			if push_dir.length_squared() > 0:
				push_dir = push_dir.normalized()
				# Use force instead of impulse for smoother pushing
				# Scale by mass so heavier objects feel heavier
				rigid.apply_central_force(push_dir * push_force * rigid.mass * 60.0)
