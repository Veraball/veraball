extends Spatial

var global
var body_node
var ray_node
var camera_node
var yaw_node
var pitch_node
var impulse_indicator_v_node
var impulse_indicator_h_node
var rolling_sound_node
var landing_sound_node

export var acceleration = 10.0
export var jump_velocity = 1.0

var yaw = 0
var pitch = 0
var view_sensitivity

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
	impulse_indicator_v_node = get_node("Yaw/ImpulseIndicatorV")
	impulse_indicator_h_node = get_node("Yaw/ImpulseIndicatorH")
	rolling_sound_node = get_node("RollingSound")
	landing_sound_node = get_node("LandingSound")
	global = get_node("/root/Global")
	
	view_sensitivity = global.view_sensitivity

	set_process_input(true)
	set_fixed_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		yaw = fmod(yaw - event.relative_x * view_sensitivity, 360)
		# Prevent yaw from becoming negative:
		if yaw < 0:
			yaw = 359.75
		pitch = max(min(pitch - event.relative_y * view_sensitivity, 89), -89)
		yaw_node.set_rotation(Vector3(0, deg2rad(yaw), 0))
		pitch_node.set_rotation(Vector3(deg2rad(pitch), 0, 0))

func _fixed_process(delta):
	# Move camera, sample players and ray with the ball (but don't rotate them)
	yaw_node.set_translation(body_node.get_translation())
	ray_node.set_translation(body_node.get_translation())
	rolling_sound_node.set_translation(body_node.get_translation())
	landing_sound_node.set_translation(body_node.get_translation())

	v_diff_x = body_node.get_global_transform().origin.x - impulse_indicator_v_node.get_global_transform().origin.x
	v_diff_z = body_node.get_global_transform().origin.z - impulse_indicator_v_node.get_global_transform().origin.z
	
	h_diff_x = body_node.get_global_transform().origin.x - impulse_indicator_h_node.get_global_transform().origin.x
	h_diff_z = body_node.get_global_transform().origin.z - impulse_indicator_h_node.get_global_transform().origin.z
	
	velocity = body_node.get_linear_velocity()

	# Handle input
	if Input.is_action_pressed("move_forwards"):
		velocity += Vector3(v_diff_x * delta * acceleration, 0, v_diff_z * delta * acceleration)
		body_node.set_linear_velocity(velocity)

	if Input.is_action_pressed("move_backwards"):
		velocity += Vector3(-v_diff_x * delta * acceleration, 0, -v_diff_z * delta * acceleration)
		body_node.set_linear_velocity(velocity)

	if Input.is_action_pressed("move_left"):
		velocity += Vector3(h_diff_x * delta * acceleration, 0, h_diff_z * delta * acceleration)
		body_node.set_linear_velocity(velocity)

	if Input.is_action_pressed("move_right"):
		velocity += Vector3(-h_diff_x * delta * acceleration, 0, -h_diff_z * delta * acceleration)
		body_node.set_linear_velocity(velocity)

	if Input.is_action_pressed("jump") and ray_node.is_colliding():
		velocity += Vector3(0, jump_velocity, 0)
		body_node.set_linear_velocity(velocity)
		play_landing_sound = true

	# If colliding, the rolling sound can be played. Else, it's not and it's immediately stopped.
	if ray_node.is_colliding():
		play_rolling_sound = true
	else:
		play_rolling_sound = false
		get_node("RollingSound").stop_all()

	# Rolling sound
	if play_rolling_sound and not get_node("RollingSound").is_voice_active(0):
		get_node("RollingSound").play("roll", 0)
	
	# Volume varies depending on speed
	if play_rolling_sound:
		var volume = body_node.get_linear_velocity().length() - 16
		# Cap volume
		if volume >= 4:
			volume = 4
		get_node("RollingSound").voice_set_volume_scale_db(0, volume)

	# Jumping sound
	# FIXME: Make it a landing sound, rather than jumping
	if ray_node.is_colliding() and play_landing_sound:
		get_node("LandingSound").play("land")
		play_landing_sound = false

# Called when the game is quit, or when player goes back to main menu
func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
