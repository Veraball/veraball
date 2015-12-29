extends Control

# This is needed for some reason :(
onready var Game = get_node("/root/Game")
# Variables and timer for FPS display interpolation
var fps_old = 0
var fps_old_temp = 0
var fps_new = 0
var fps_show = 0
var timer = Timer.new()

func _ready():
	timer.set_timer_process_mode(timer.TIMER_PROCESS_FIXED)
	timer.set_wait_time(1.0)
	timer.set_autostart(true)
	timer.connect("timeout", get_node("."), "_on_Timer_timeout")
	add_child(timer)
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
	fps_old_temp = OS.get_frames_per_second()
	fps_new = OS.get_frames_per_second()

	# Set the values
	# The interpolation isn't as good as it ought to be, since fps_old isn't 1 second older than fps_new, but more like ~0.4 second)
	fps_show = round(lerp(fps_old, fps_new, 1 - timer.get_time_left()))
	get_node("FramesPerSecond").set_text(str(fps_show) + " FPS")
	get_node("Panel/CoinsCount").set_text(str(Game.coins))
	get_node("Panel/CoinsProgress").set_value(int(Game.coins))
	get_node("Panel/CoinsProgress").set_max(int(Game.coins_total))
	get_node("Panel/TimeLabel").set_text(str(Game.make_game_time_string(Game.game_time)))
	get_node("Panel/TimeLabel").set("custom_colors/font_color", Color(1, ((Game.game_time_max - Game.game_time) / Game.game_time_max), ((Game.game_time_max - Game.game_time) / Game.game_time_max)))
	# Show countdown when the game hasn't started yet:
	if Game.game_countdown > 0:
		get_node("Panel/TimeLabel").set_text(str(Game.make_game_time_string(-Game.game_countdown)))
		get_node("Panel/TimeLabel").set("custom_colors/font_color", Color((Game.game_countdown / Game.GAME_COUNTDOWN_DEFAULT), 1, (Game.game_countdown / Game.GAME_COUNTDOWN_DEFAULT)))
	get_node("Panel/TimeProgress").set_max(Game.game_time_max)
	get_node("Panel/TimeProgress").set_value(Game.game_time_max - Game.game_time)
	get_node("Panel/BoostCount").set_text(str((Game.boost / 6) * 100).pad_decimals(1) + "%")
	get_node("Panel/BoostProgress").set_value(float(Game.boost))

func _on_Timer_timeout():
	fps_old = fps_old_temp
