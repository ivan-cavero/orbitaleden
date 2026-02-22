class_name ScreenEffects
extends CanvasLayer
## Post-processing overlay driven by survival stat signals.
##
## Manages:
##   1. Vignette         — ramps in as oxygen falls below 30%
##   2. Desaturation     — ramps in as oxygen falls below 30%
##   3. Unconscious fade — full-screen black fade + drives Engine.time_scale
##                         when PlayerSurvival emits unconscious_tick(progress)
##
## Usage (from main.gd):
##   fx.setup(player.get_node("Survival"))

# ─────────────────────────────────────────────────────────────────────────────
# Constants
# ─────────────────────────────────────────────────────────────────────────────

## Oxygen ratio below which vignette/desaturation begin.
const O2_LOW_THRESHOLD: float = 0.3

## How fast the vignette/saturation smoothly interpolate (units per second).
const EFFECT_LERP_SPEED: float = 2.0

## Minimum time_scale during unconscious fade (player almost frozen).
const MIN_TIME_SCALE: float = 0.05

# ─────────────────────────────────────────────────────────────────────────────
# Exports
# ─────────────────────────────────────────────────────────────────────────────

@export var effects_enabled: bool = true

# ─────────────────────────────────────────────────────────────────────────────
# Private state
# ─────────────────────────────────────────────────────────────────────────────

var _env: Environment = null
var _vignette: ColorRect = null
var _vignette_mat: ShaderMaterial = null
var _survival: Node = null

## Smoothed current values.
var _cur_vignette: float  = 0.0
var _cur_saturation: float = 1.0
var _cur_fade: float       = 0.0

## Targets set by signals / per-frame poll.
var _tgt_vignette: float  = 0.0
var _tgt_saturation: float = 1.0
var _tgt_fade: float       = 0.0

## True while oxygen is at 0 (from signal).
var _o2_depleted: bool = false
var _unconscious_progress: float = 0.0

## Damage flash overlay.
var _flash_rect: ColorRect = null
var _flash_color: Color = Color.TRANSPARENT
var _flash_timer: float = 0.0
var _flash_duration: float = 0.0

# ─────────────────────────────────────────────────────────────────────────────
# Lifecycle
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	# Layer 5: above game world, below HUD and debug overlay.
	layer = 5

	_vignette = ColorRect.new()
	_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader := load("res://ui/hud/vignette.gdshader") as Shader
	if shader:
		_vignette_mat = ShaderMaterial.new()
		_vignette_mat.shader = shader
		_vignette.material = _vignette_mat
	else:
		Debug.warn("ScreenEffects: vignette shader not found")

	add_child(_vignette)

	# Flash rect sits on top of the vignette.
	_flash_rect = ColorRect.new()
	_flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_rect.color = Color.TRANSPARENT
	add_child(_flash_rect)


func _process(delta: float) -> void:
	if not effects_enabled:
		_reset_all()
		return

	_compute_targets()

	# Use real delta for UI lerp (unaffected by time_scale slowdown).
	var real_delta := delta / Engine.time_scale if Engine.time_scale > 0.0 else delta
	_cur_vignette   = move_toward(_cur_vignette,   _tgt_vignette,   EFFECT_LERP_SPEED * real_delta)
	_cur_saturation = move_toward(_cur_saturation, _tgt_saturation, EFFECT_LERP_SPEED * real_delta)
	_cur_fade       = move_toward(_cur_fade,       _tgt_fade,       EFFECT_LERP_SPEED * real_delta)

	_apply_vignette(_cur_vignette)
	_apply_fade(_cur_fade)
	_apply_saturation(_cur_saturation)

	# Drive time_scale from unconscious progress.
	if _o2_depleted:
		var slowdown := lerpf(1.0, MIN_TIME_SCALE, _unconscious_progress)
		Engine.time_scale = slowdown
	else:
		# Ease time_scale back to 1.0 after consciousness restored.
		Engine.time_scale = move_toward(Engine.time_scale, 1.0, 2.0 * real_delta)

	_tick_flash(real_delta)


# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

func setup(survival: Node) -> void:
	_survival = survival

	# Connect survival signals.
	if _survival.has_signal("unconscious_tick"):
		_survival.unconscious_tick.connect(_on_unconscious_tick)
	if _survival.has_signal("consciousness_restored"):
		_survival.consciousness_restored.connect(_on_consciousness_restored)

	# Find WorldEnvironment.
	_env = _find_environment()
	if _env == null:
		Debug.warn("ScreenEffects: WorldEnvironment not found — saturation effect disabled")
	else:
		_env.adjustment_enabled  = true
		_env.adjustment_saturation = 1.0
		Debug.info("ScreenEffects ready — environment adjustment enabled")


## Trigger a full-screen colour flash (e.g. damage hit).
## [param color]    — the flash tint (include desired alpha for peak opacity)
## [param duration] — seconds until fully faded (default 0.35s)
func flash(color: Color, duration: float = 0.35) -> void:
	_flash_color    = color
	_flash_duration = maxf(duration, 0.05)
	_flash_timer    = 0.0
	if is_instance_valid(_flash_rect):
		_flash_rect.color = color


# ─────────────────────────────────────────────────────────────────────────────
# Signal handlers
# ─────────────────────────────────────────────────────────────────────────────

func _on_unconscious_tick(progress: float) -> void:
	_o2_depleted = true
	_unconscious_progress = progress


func _on_consciousness_restored() -> void:
	_o2_depleted = false
	_unconscious_progress = 0.0


# ─────────────────────────────────────────────────────────────────────────────
# Private helpers
# ─────────────────────────────────────────────────────────────────────────────

func _compute_targets() -> void:
	if _o2_depleted:
		# Unconscious fade overrides everything.
		# progress 0→1: vignette up, saturation down, then fade to black.
		var p := _unconscious_progress
		_tgt_vignette   = minf(p * 2.0, 1.0)           # vignette hits 1 at p=0.5
		_tgt_saturation = 1.0 - p                       # fully greyscale at p=1
		_tgt_fade       = maxf(0.0, (p - 0.5) * 2.0)   # fade starts at p=0.5
		return

	# Oxygen low (but not 0) → vignette + desaturation.
	if not is_instance_valid(_survival):
		_tgt_vignette   = 0.0
		_tgt_saturation = 1.0
		_tgt_fade       = 0.0
		return

	var snap: Dictionary = _survival.get_debug_snapshot()
	var o2_pair: Array   = snap.get("oxygen", [100.0, 100.0])
	var o2_ratio: float  = (o2_pair[0] / o2_pair[1]) if o2_pair[1] > 0.0 else 0.0

	if o2_ratio < O2_LOW_THRESHOLD and o2_ratio > 0.0:
		var t := 1.0 - (o2_ratio / O2_LOW_THRESHOLD)   # 0 at threshold → 1 at 0%
		_tgt_vignette   = t * 0.7
		_tgt_saturation = 1.0 - t * 0.7
	else:
		_tgt_vignette   = 0.0
		_tgt_saturation = 1.0

	_tgt_fade = 0.0


func _apply_vignette(intensity: float) -> void:
	if is_instance_valid(_vignette_mat):
		_vignette_mat.set_shader_parameter("vignette_intensity", intensity)


func _apply_fade(intensity: float) -> void:
	if is_instance_valid(_vignette_mat):
		_vignette_mat.set_shader_parameter("fade_intensity", intensity)


func _apply_saturation(saturation: float) -> void:
	if is_instance_valid(_env):
		_env.adjustment_saturation = saturation


func _reset_all() -> void:
	_apply_vignette(0.0)
	_apply_fade(0.0)
	_apply_saturation(1.0)
	_cur_vignette   = 0.0
	_cur_saturation = 1.0
	_cur_fade       = 0.0
	Engine.time_scale = 1.0


func _tick_flash(real_delta: float) -> void:
	if _flash_duration <= 0.0 or not is_instance_valid(_flash_rect):
		return
	_flash_timer += real_delta
	var t := clampf(_flash_timer / _flash_duration, 0.0, 1.0)
	_flash_rect.color = Color(_flash_color.r, _flash_color.g, _flash_color.b,
							  _flash_color.a * (1.0 - t))
	if _flash_timer >= _flash_duration:
		_flash_duration = 0.0
		_flash_rect.color = Color.TRANSPARENT


func _find_environment() -> Environment:
	# Search by WorldEnvironment node type in the scene tree.
	var we: Node = get_tree().root.find_child("WorldEnvironment", true, false)
	if is_instance_valid(we) and we is WorldEnvironment:
		return (we as WorldEnvironment).environment
	return null
