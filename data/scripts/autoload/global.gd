extends Node

# Levels, the autoload containing the level list
var levels
# Developer, the autoload managing debugging options
var developer

# Game variables
var coins = 0
var game_time = 0.0
var game_time_string = "00.00"
var current_level_id = -1 # -1 when in main menu
var clock_running = true
var music_pending = "1"

# HACK: Prevent fullscreen from "flickering" by having at least 0.1 second of
# delay between switches
var toggle_fullscreen_timer = 0.0
const TOGGLE_FULLSCREEN_TIMER_MAX = 0.1

# Options
var view_sensitivity = 0.15

func play_main_menu_music():
	get_node("/root/Music").play("1")

func _ready():
	play_main_menu_music()
	window_setup()
	levels = get_node("/root/Levels")
	developer = get_node("/root/Developer")
	reset_window_title()

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
		if OS.is_window_fullscreen() and toggle_fullscreen_timer >= TOGGLE_FULLSCREEN_TIMER_MAX:
			OS.set_window_fullscreen(false)
			toggle_fullscreen_timer = 0.0
		elif toggle_fullscreen_timer >= TOGGLE_FULLSCREEN_TIMER_MAX:
			OS.set_window_fullscreen(true)
			toggle_fullscreen_timer = 0.0

func _fixed_process(delta):
	if clock_running:
		game_time += delta

	toggle_fullscreen_timer += delta
	if toggle_fullscreen_timer >= TOGGLE_FULLSCREEN_TIMER_MAX:
		toggle_fullscreen_timer = TOGGLE_FULLSCREEN_TIMER_MAX

# Change level ID safely (for use with PageUp/PageDown)
func change_level_id(ID):
	if ID <= 0:
		return 0
	elif ID >= levels.list.size():
		return levels.list.size()
	else:
		return ID

# Reset window title to the default (main menu)
func reset_window_title():
	OS.set_window_title("(Main Menu) - Veraball")

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

func make_subtitle(text):
	return "[center][color=#ffff00]" + tr(text) + "[/color][/center]"

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
	var filename = levels.list[level_id][1]
	# Don't change level if level is the same
	# (usually caused by being at the top or bottom of level list)
	if current_level_id == level_id:
		return
	get_tree().change_scene("res://data/maps/" + filename + "/" + filename + ".xscn")
	get_node("/root/Global/HUD").show()
	reset_game_state()

	# Read level information (which is used to set total coins and coins required),
	# and while we're at it, set the music to be played
	music_pending = read_level_information(level_id)["music"]
	current_level_id = level_id
	
	# Change window title to contain the full name of the current level
	OS.set_window_title(levels.list[level_id][0] + " - Veraball")
	get_node("/root/Music").play(music_pending)

# Restart level
func restart_level():
	get_tree().reload_current_scene()
	reset_game_state()

# Go to main menu
func go_to_main_menu():
	get_tree().change_scene("res://data/scenes/menu/main.xscn")
	play_main_menu_music()
	clock_running = true
	game_time = 0
	current_level_id = -1
	get_node("/root/Global/HUD").hide()
	get_node("/root/Global/CenterPrint").hide()
	reset_window_title()

var name = ""
var description = ""
var coins_total = 0
var coins_required = 0
var music = "1"

# Read level information: full name, description, total coins, coins required to pass
func read_level_information(level_id):
	var filename = levels.list[level_id][1]
	var config = ConfigFile.new()
	config.load("res://data/maps/" + filename + "/" + filename + ".ini")
	name = config.get_value("level", "name")
	description = config.get_value("level", "description")
	coins_total = config.get_value("level", "coins_total")
	coins_required = config.get_value("level", "coins_required")
	music = config.get_value("level", "music")
	developer.print_verbose("Reading level information " + filename + ".ini.")
	return {"name": name, "description": description, "coins_total": coins_total, "coins_required": coins_required, "music": music}