extends Node

# Levels, the autoload containing the level list
var levels

# Game variables
var coins = 0
var coins_total = 0
var coins_required = 0
var game_time = 0.0
var game_time_string = "00.00"
var current_level_id = -1 # -1 when in main menu
var clock_running = true

# HACK: Prevent fullscreen from "flickering" by having at least 0.1 second of
# delay between switches
var change_fullscreen_timer = 0.0
const change_fullscreen_timer_max = 0.1

# Options
var view_sensitivity = 0.15

func _ready():
	window_setup()
	levels = get_node("/root/Levels")

	set_fixed_process(true)
	set_process_input(true)

	# Add HUD
	var hud_scene = preload("res://data/scenes/hud/main.xscn")
	var hud = hud_scene.instance()
	get_node("/root/Global").add_child(hud)

	# Add centerprint
	var centerprint_scene = preload("res://data/scenes/hud/centerprint.xscn")
	var centerprint = centerprint_scene.instance()
	add_child(centerprint)

func _input(event):
	if Input.is_action_pressed("quit_game") and not is_in_main_menu():
		go_to_main_menu()
	
	if Input.is_action_pressed("restart_level") and not is_in_main_menu():
		restart_level()

	# Go up one level ID
	if Input.is_action_pressed("level_previous") and not is_in_main_menu():
		start_game(change_level_id(-1))

	# Go down one level ID
	if Input.is_action_pressed("level_next") and not is_in_main_menu():
		start_game(change_level_id(1))

	if Input.is_action_pressed("toggle_fullscreen"):
		if OS.is_window_fullscreen() and change_fullscreen_timer >= 0.1:
			OS.set_window_fullscreen(false)
			change_fullscreen_timer = 0.0
		elif change_fullscreen_timer >= change_fullscreen_timer_max:
			OS.set_window_fullscreen(true)
			change_fullscreen_timer = 0.0

func _fixed_process(delta):
	if clock_running:
		game_time += delta

	change_fullscreen_timer += delta
	if change_fullscreen_timer >= change_fullscreen_timer_max:
		change_fullscreen_timer = change_fullscreen_timer_max

# Change level ID safely (for use with PageUp/PageDown)
func change_level_id(ID):
	if ID <= 0:
		return 0
	elif ID >= levels.list.size():
		return levels.list.size()
	else:
		return ID

# The game is designed for 1920x1080 screens, but most players don't have such
# a resolution. So, a resolution of 1920x1080 is specified in the project
# settings, but the game will actually start in 1024x576, a 16:9 resolution
# that pretty much works everywhere. The window is made non-maximized to
# ensure it is actually being resized.
func window_setup():
	OS.set_window_maximized(false)
	OS.set_window_size(Vector2(1024, 576))

# Returns a string with leading and trailing zeroes as needed
func make_game_time_string(time):
	return str(floor(time * 100) / 100).pad_decimals(2).pad_zeros(2)

func centerprint(text):
	get_node("/root/Global/CenterPrint").show()
	get_node("/root/Global/CenterPrint/RichTextLabel").set_bbcode("[center]" + tr(text) + "[/center]")
	if text != "":
		get_node("/root/Global/CenterPrint/AnimationPlayer").play("Fade")

# Makes a string into a title using BBCode
func make_title(text):
	return "[center][b][color=#ffff00]" + tr(text) + "[/color][/b][/center]"

func reset_game_state():
	coins = 0
	game_time = 0
	clock_running = true
	# Output a blank centerprint to clear any current centerprints
	centerprint("")

# Function that returns whether the player is in main menu
func is_in_main_menu():
	if get_tree().get_current_scene().get_filename() == "res://data/scenes/menu/main.xscn":
		return true
	else:
		return false

# Toggle game pause (currently unused)
func pause_game():
	if get_tree().is_paused():
		get_tree().set_pause(false)
	else:
		get_tree().set_pause(true)

func start_game(level_id):
	# Don't change level if level is the same
	# (usually caused by being at the top or bottom of level list)
	if current_level_id == level_id:
		return
	get_tree().change_scene("res://data/maps/" + levels.list[level_id][1] + "/" + levels.list[level_id][1] + ".xscn")
	get_node("/root/Global/HUD").show()
	reset_game_state()
	current_level_id = level_id

# Restart level
func restart_level():
	get_tree().reload_current_scene()
	reset_game_state()

# Go to main menu
func go_to_main_menu():
	get_tree().change_scene("res://data/scenes/menu/main.xscn")
	clock_running = true
	game_time = 0
	current_level_id = -1
	get_node("/root/Global/HUD").hide()
	get_node("/root/Global/CenterPrint").hide()