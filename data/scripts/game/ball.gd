extends Spatial

onready var body_node = get_node("RigidBody")
onready var ray_node = get_node("RayCast")
onready var camera_node = get_node("Yaw/Pitch/Camera")
onready var yaw_node = get_node("Yaw")
onready var pitch_node = get_node("Yaw/Pitch")
onready var night_light_node = get_node("Smoothing/NightLight")
onready var boost_light_node = get_node("Smoothing/BoostLight")
onready var impulse_indicator_v_node = get_node("Yaw/ImpulseIndicatorV")
onready var impulse_indicator_h_node = get_node("Yaw/ImpulseIndicatorH")
onready var sounds_node = get_node("Smoothing/Sounds")

var acceleration = 12.0
var jump_velocity = 1.0
const BOOST_FACTOR = 1.667

var yaw = 0
var pitch = 0

var play_landing_sound = false
var play_rolling_sound = false

var velocity = Vector3(0, 0, 0)

# "Vertical" and "horizontal" differences between the ball and imaginary pivots
var v_diff_x
var v_diff_z
var h_diff_x
var h_diff_z

func _ready() -> void:
	# Capture mouse input when starting the game (for mouse look to work)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	night_light_node.visible = Levels.is_night_level(Game.current_level_id)


# Mouse look
func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		yaw = fmod(yaw - event.relative.x * Game.view_sensitivity * 0.05, 360)
		# Prevent yaw from becoming negative:
		if yaw < 0:
			yaw = 359.75
		pitch = max(min(pitch - event.relative.y * Game.view_sensitivity * 0.05, 89), -89)
		yaw_node.set_rotation(Vector3(0, deg2rad(yaw), 0))
		pitch_node.set_rotation(Vector3(deg2rad(pitch), 0, 0))


func integrate_forces(state: PhysicsDirectBodyState) -> void:
	v_diff_x = body_node.get_global_transform().origin.x - impulse_indicator_v_node.get_global_transform().origin.x
	v_diff_z = body_node.get_global_transform().origin.z - impulse_indicator_v_node.get_global_transform().origin.z

	h_diff_x = body_node.get_global_transform().origin.x - impulse_indicator_h_node.get_global_transform().origin.x
	h_diff_z = body_node.get_global_transform().origin.z - impulse_indicator_h_node.get_global_transform().origin.z

	# Handle input, but only while the clock is running (can't input during intermission or countdown).
	if Input.is_action_pressed("move_forwards") and Game.clock_running:
		body_node.linear_velocity += Vector3(
				v_diff_x * state.step * acceleration * Game.acceleration_factor,
				0,
				v_diff_z * state.step * acceleration * Game.acceleration_factor
		)

	if Input.is_action_pressed("move_backwards") and Game.clock_running:
		body_node.linear_velocity += Vector3(
				-v_diff_x * state.step * acceleration * Game.acceleration_factor,
				0,
				-v_diff_z * state.step * acceleration * Game.acceleration_factor
		)

	if Input.is_action_pressed("move_left") and Game.clock_running:
		body_node.linear_velocity += Vector3(
				h_diff_x * state.step * acceleration * Game.acceleration_factor,
				0,
				h_diff_z * state.step * acceleration * Game.acceleration_factor
		)

	if Input.is_action_pressed("move_right") and Game.clock_running:
		body_node.linear_velocity += Vector3(
				-h_diff_x * state.step * acceleration * Game.acceleration_factor,
				0,
				-h_diff_z * state.step * acceleration * Game.acceleration_factor
		)

	if Input.is_action_pressed("jump") and ray_node.is_colliding() and Game.clock_running:
		body_node.linear_velocity += Vector3(0, jump_velocity, 0)
		play_landing_sound = true


func _physics_process(delta):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	# Move camera, sample players and ray with the ball (but don't rotate them)
	if Game.camera_follows_ball:
		yaw_node.set_translation(body_node.get_translation())
	ray_node.set_translation(body_node.get_translation())
	sounds_node.set_translation(body_node.get_translation())
	night_light_node.set_translation(body_node.get_translation())
	boost_light_node.set_translation(body_node.get_translation())

	# Cap boost
	if Game.boost <= 0:
		Game.boost = 0
	elif Game.boost >= 6:
		Game.boost = 6

	# Boost mechanics, particles and sounds
	if Input.is_action_pressed("boost") and is_moving() and Game.boost > 0.01 and Game.clock_running:
		Game.acceleration_factor = BOOST_FACTOR
		get_node("Smoothing/BoostParticles").set_emitting(true)
		Game.boost -= delta
		boost_light_node.visible = true
		get_node("Smoothing/BoostLight/Sprite3D").show()
		#if not get_node("Sounds").is_voice_active(1):
		#	get_node("Sounds").play("boost", 1)
	# If having almost no boost, do nothing (to prevent "flickering" between boosting and non-boosting states)
	elif Input.is_action_pressed("boost") and Game.boost < 0.01:
		Game.acceleration_factor = 1.0
		boost_light_node.visible = true
		get_node("Smoothing/BoostLight/Sprite3D").hide()
		get_node("Smoothing/BoostParticles").emitting = false
		#get_node("Sounds").stop_voice(1)
	else:
		Game.acceleration_factor = 1.0
		boost_light_node.visible = true
		get_node("Smoothing/BoostLight/Sprite3D").hide()
		get_node("Smoothing/BoostParticles").emitting = false
		#get_node("Sounds").stop_voice(1)
		if Game.clock_running:
			# The faster you move, the faster boost regenerates
			Game.boost += delta * 0.0125 * Vector3(velocity.x, 0, velocity.z).length()

	# If colliding, the rolling sound can be played. Else, it's not and it's immediately stopped.
	if ray_node.is_colliding():
		play_rolling_sound = true
	else:
		play_rolling_sound = false
		#get_node("Sounds").stop_voice(0)

	# Rolling sound
	#if play_rolling_sound and not get_node("Sounds").is_voice_active(0):
	#	get_node("Sounds").play("roll", 0)

	# Volume varies depending on speed
	if play_rolling_sound:
		var volume = body_node.get_linear_velocity().length() - 16
		# Cap volume
		if volume >= 4:
			volume = 4
		#get_node("Sounds").voice_set_volume_scale_db(0, volume)

	# Jumping sound
	# FIXME: Make it a landing sound, rather than jumping
	if ray_node.is_colliding() and play_landing_sound:
		#get_node("Sounds").play("land", 2)
		play_landing_sound = false


# Called when the game is quit, or when the player goes back to main menu.
func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func is_moving():
	return Input.is_action_pressed("move_forwards") or Input.is_action_pressed("move_backwards") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")
