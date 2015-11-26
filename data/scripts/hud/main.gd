extends Control

var global
var coins
var coins_total
var game_time
var boost

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	get_node("FramesPerSecond").hide()

func _input(event):
	if Input.is_action_pressed("toggle_fps_display"):
		if get_node("FramesPerSecond").is_visible():
			get_node("FramesPerSecond").hide()
		else:
			get_node("FramesPerSecond").show()

func _fixed_process(delta):
	global = get_node("/root/Global")
	coins = global.coins
	coins_total = global.coins_total
	boost = global.boost

	# Set the values
	get_node("FramesPerSecond").set_text(str(OS.get_frames_per_second()) + " FPS")
	get_node("Panel/CoinsCount").set_text(str(coins))
	get_node("Panel/CoinsProgress").set_value(int(coins))
	get_node("Panel/CoinsProgress").set_max(int(coins_total))
	get_node("Panel/TimeLabel").set_text(str(global.make_game_time_string(global.game_time)))
	get_node("Panel/TimeLabel").set("custom_colors/font_color", Color(1, ((global.game_time_max - global.game_time) / global.game_time_max), ((global.game_time_max - global.game_time) / global.game_time_max)))
	# Show countdown when the game hasn't started yet:
	if global.game_countdown > 0:
		get_node("Panel/TimeLabel").set_text(str(global.make_game_time_string(-global.game_countdown)))
		get_node("Panel/TimeLabel").set("custom_colors/font_color", Color((global.game_countdown / global.GAME_COUNTDOWN_DEFAULT), 1, (global.game_countdown / global.GAME_COUNTDOWN_DEFAULT)))
	get_node("Panel/TimeProgress").set_max(global.game_time_max)
	get_node("Panel/TimeProgress").set_value(global.game_time_max - global.game_time)
	get_node("Panel/BoostCount").set_text(str((global.boost / 6) * 100).pad_decimals(1) + "%")
	get_node("Panel/BoostProgress").set_value(float(global.boost))
