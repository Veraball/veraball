extends Spatial

var global
var levels

var body_node
var ray_node
var camera_node
var yaw_node
var pitch_node
var impulse_indicator_v_node
var impulse_indicator_h_node
var sounds_node
var night_light_node
var boost_light_node

var acceleration = 12.0
var jump_velocity = 1.0
const BOOST_FACTOR = 1.667

var yaw = 0
var pitch = 0
var view_sensitivity

var acceleration_factor
var play_landing_sound = false
var play_rolling_sound = false

var velocity = Vector3(0, 0, 0)

# "Vertical" and "horizontal" differences between the ball and imaginary pivots
var v_diff_x
var v_diff_z
var h_diff_x
var h_diff_z

func _ready():
	view_sensitivity = get_node("/root/Global").view_sensitivity
	body_node = get_node("RigidBody")
	ray_node = get_node("RayCast")
	camera_node = get_node("Yaw/Pitch/Camera")
	yaw_node = get_node("Yaw")
	pitch_node = get_node("Yaw/Pitch")
	night_light_node = get_node("NightLight")
	boost_light_node = get_node("BoostLight")
	impulse_indicator_v_node = get_node("Yaw/ImpulseIndicatorV")
	impulse_indicator_h_node = get_node("Yaw/ImpulseIndicatorH")
	sounds_node = get_node("Sounds")
	global = get_node("/root/Global")
	levels = get_node("/root/Levels")
	acceleration_factor = global.acceleration_factor

	view_sensitivity = global.view_sensitivity

	set_process_input(true)
	set_fixed_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if levels.is_night_level(global.current_level_id):
		get_node("NightLight").set_enabled(true)
	else:
		get_node("NightLight").set_enabled(false)

# Mouse look
func _input(event):
	if event.type == InputEvent.MOUSE_MOTION and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw = fmod(yaw - event.relative_x * view_sensitivity * 0.05, 360)
		# Prevent yaw from becoming negative:
		if yaw < 0:
			yaw = 359.75
		pitch = max(min(pitch - event.relative_y * view_sensitivity * 0.05, 89), -89)
		yaw_node.set_rotation(Vector3(0, deg2rad(yaw), 0))
		pitch_node.set_rotation(Vector3(deg2rad(pitch), 0, 0))

func _fixed_process(delta):
	# Move camera, sample players and ray with the ball (but don't rotate them)
	if global.camera_follows_ball:
		yaw_node.set_translation(body_node.get_translation())
	ray_node.set_translation(body_node.get_translation())
	sounds_node.set_translation(body_node.get_translation())
	night_light_node.set_translation(body_node.get_translation())
	boost_light_node.set_translation(body_node.get_translation())
	
	# Cap boost
	if global.boost <= 0:
		global.boost = 0
	elif global.boost >= 6:
		global.boost = 6

	# Boost mechanics, particles and sounds
	if Input.is_action_pressed("boost") and is_moving() and global.boost > 0.01 and global.clock_running:
		acceleration_factor = BOOST_FACTOR
		get_node("RigidBody/BoostParticles").set_emitting(true)
		global.boost -= delta
		boost_light_node.set_enabled(true)
		get_node("BoostLight/Sprite3D").show()
		if not get_node("Sounds").is_voice_active(1):
			get_node("Sounds").play("boost", 1)
	# If having almost no boost, do nothing (to prevent "flickering" between boosting and non-boosting states)
	elif Input.is_action_pressed("boost") and global.boost < 0.01:
		acceleration_factor = 1.0
		boost_light_node.set_enabled(false)
		get_node("BoostLight/Sprite3D").hide()
		get_node("RigidBody/BoostParticles").set_emitting(false)
		get_node("Sounds").stop_voice(1)
	else:
		acceleration_factor = 1.0
		boost_light_node.set_enabled(false)
		get_node("BoostLight/Sprite3D").hide()
		get_node("RigidBody/BoostParticles").set_emitting(false)
		get_node("Sounds").stop_voice(1)
		if global.clock_running:
			# The faster you move, the faster boost regenerates
			global.boost += delta * 0.0125 * Vector3(velocity.x, 0, velocity.z).length()

	v_diff_x = body_node.get_global_transform().origin.x - impulse_indicator_v_node.get_global_transform().origin.x
	v_diff_z = body_node.get_global_transform().origin.z - impulse_indicator_v_node.get_global_transform().origin.z
	
	h_diff_x = body_node.get_global_transform().origin.x - impulse_indicator_h_node.get_global_transform().origin.x
	h_diff_z = body_node.get_global_transform().origin.z - impulse_indicator_h_node.get_global_transform().origin.z
	
	velocity = body_node.get_linear_velocity()

	# Handle input, but only while the clock is running (can't input during intermission or countdown)
	if Input.is_action_pressed("move_forwards") and global.clock_running:
		velocity += Vector3(v_diff_x * delta * acceleration * acceleration_factor, 0, v_diff_z * delta * acceleration * acceleration_factor)
		body_node.set_linear_velocity(velocity)

	if Input.is_action_pressed("move_backwards") and global.clock_running:
		velocity += Vector3(-v_diff_x * delta * acceleration * acceleration_factor, 0, -v_diff_z * delta * acceleration * acceleration_factor)
		body_node.set_linear_velocity(velocity)

	if Input.is_action_pressed("move_left") and global.clock_running:
		velocity += Vector3(h_diff_x * delta * acceleration * acceleration_factor, 0, h_diff_z * delta * acceleration * acceleration_factor)
		body_node.set_linear_velocity(velocity)

	if Input.is_action_pressed("move_right") and global.clock_running:
		velocity += Vector3(-h_diff_x * delta * acceleration * acceleration_factor, 0, -h_diff_z * delta * acceleration * acceleration_factor)
		body_node.set_linear_velocity(velocity)

	if Input.is_action_pressed("jump") and ray_node.is_colliding() and global.clock_running:
		velocity += Vector3(0, jump_velocity, 0)
		body_node.set_linear_velocity(velocity)
		play_landing_sound = true

	# If colliding, the rolling sound can be played. Else, it's not and it's immediately stopped.
	if ray_node.is_colliding():
		play_rolling_sound = true
	else:
		play_rolling_sound = false
		get_node("Sounds").stop_voice(0)

	# Rolling sound
	if play_rolling_sound and not get_node("Sounds").is_voice_active(0):
		get_node("Sounds").play("roll", 0)

	# Volume varies depending on speed
	if play_rolling_sound:
		var volume = body_node.get_linear_velocity().length() - 16
		# Cap volume
		if volume >= 4:
			volume = 4
		get_node("Sounds").voice_set_volume_scale_db(0, volume)

	# Jumping sound
	# FIXME: Make it a landing sound, rather than jumping
	if ray_node.is_colliding() and play_landing_sound:
		get_node("Sounds").play("land", 2)
		play_landing_sound = false

# Called when the game is quit, or when player goes back to main menu
func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func is_moving():
	if Input.is_action_pressed("move_forwards") or Input.is_action_pressed("move_backwards") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		return true
	else:
		return false
