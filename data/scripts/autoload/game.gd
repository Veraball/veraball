extends Node

# Countdown before every game
const GAME_COUNTDOWN_DEFAULT = 2.5
# The mouse sensitivity in the game
var view_sensitivity = 0.15
# Game variables
var coins = 0
# No boost when you start, it regenerates
var boost = 0
var game_countdown = GAME_COUNTDOWN_DEFAULT
var game_time = 0.0
var game_time_string = "00.00"
# Time before player loses (per-level)
var game_time_max = 30.0
# -1 when in main menu
var current_level_id = -1
var clock_running = false
var music_pending = "1"
var camera_follows_ball = true
# Global factor for acceleration (used for boost)
var acceleration_factor = 1.0

func play_main_menu_music():
	Music.play("1")

func _ready():
	play_main_menu_music()
	window_setup()
	reset_window_title()

	set_physics_process(true)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	set_process_input(true)

	# Add HUD
	var hud_scene = load("res://data/scenes/hud/main.tscn")
	var hud = hud_scene.instance()
	add_child(hud)

	# Add centerprint (for game event notifications)
	var centerprint_scene = load("res://data/scenes/hud/centerprint.tscn")
	var centerprint = centerprint_scene.instance()
	add_child(centerprint)

func _input(event):
	if event.is_action_pressed("quit_game") and not is_in_main_menu():
		go_to_main_menu()

	if event.is_action_pressed("restart_level") and not is_in_main_menu():
		restart_level()

	# Go up one level ID
	if event.is_action_pressed("level_previous") and not is_in_main_menu():
		start_game(change_level_id(-1))

	# Go down one level ID
	if event.is_action_pressed("level_next") and not is_in_main_menu():
		start_game(change_level_id(1))

	if event.is_action_pressed("toggle_fullscreen"):
		OS.set_window_fullscreen(!OS.is_window_fullscreen())

	if event.is_action_pressed("toggle_mouse_capture") and not is_in_main_menu():
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	if clock_running:
		game_time += delta

	# Prevent moving during countdown
	if game_countdown > 0:
		clock_running = false

	# Go!
	if game_countdown <= 0 and camera_follows_ball:
		game_countdown = 0
		clock_running = true

	# Decrement countdown, while the game hasn't started yet
	if not clock_running and not is_in_main_menu():
		game_countdown -= delta

	# If player has no time left
	if game_time_max - game_time <= 0 and not is_in_main_menu():
		level_lost()

# Function that is called when the player touches the "reset" area (bottom of
# the level, usually)
func player_fall_out():
	# Only make the player lose if the clock is running (ie. level isn't finished)
	if clock_running:
		level_lost()

# Level lost (for any reason)
func level_lost():
	restart_level()
	centerprint("YouLose")

# Change level ID safely (for use with PageUp/PageDown)
func change_level_id(ID):
	if ID <= 0:
		return 0
	elif ID >= Levels.list.size():
		return Levels.list.size()
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
	get_node("/root/Game/CenterPrint").show()
	get_node("/root/Game/CenterPrint/RichTextLabel").set_bbcode("[center]" + tr(text) + "[/center]")
	if text != "":
		get_node("/root/Game/CenterPrint/AnimationPlayer").play("Fade")

# Makes a string into a title using BBCode (for menus)
func make_title(text):
	return "[center][b][color=#ffff00]" + tr(text) + "[/color][/b][/center]"

# Makes a string into a subtitle using BBCode (for menus)
func make_subtitle(text):
	return "[center][color=#ffff00]" + tr(text) + "[/color][/center]"

# Resets the game state, independently from scene reloading, currently does not
# position the ball to its starting point
func reset_game_state():
	coins = 0
	# No boost when you start, it regenerates
	boost = 0
	game_time = 0
	game_countdown = GAME_COUNTDOWN_DEFAULT
	clock_running = true
	camera_follows_ball = true
	# Output a blank centerprint to clear any current centerprints
	centerprint("")

# Function that returns whether the player is in main menu
func is_in_main_menu():
	if get_tree().get_current_scene().get_filename() == "res://data/scenes/menu/main.tscn":
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
	var filename = Levels.list[level_id][1]
	# Don't change level if level is the same
	# (usually caused by being at the top or bottom of level list)
	if current_level_id == level_id:
		return
	get_tree().change_scene("res://data/maps/" + filename + "/" + filename + ".tscn")
	get_node("/root/Game/HUD").show()
	reset_game_state()

	# Read level information (which is used to set total coins and coins required),
	# and while we're at it, set the music to be played
	music_pending = read_level_information(level_id)["music"]
	current_level_id = level_id

	# Change window title to contain the full name of the current level
	OS.set_window_title(Levels.list[level_id][0] + " - Veraball")
	get_node("/root/Music").play(music_pending)

# Restart level
func restart_level():
	get_tree().reload_current_scene()
	reset_game_state()

# Go to main menu
func go_to_main_menu():
	get_tree().change_scene("res://data/scenes/menu/main.tscn")
	play_main_menu_music()
	clock_running = true
	game_time = 0
	current_level_id = -1
	get_node("/root/Game/HUD").hide()
	get_node("/root/Game/CenterPrint").hide()
	reset_window_title()

var level_name = ""
var description = ""
var coins_total = 0
var coins_required = 0
var music = "1"

# Read level information: full name, description, total coins, coins required to pass, time available
func read_level_information(level_id):
	var filename = Levels.list[level_id][1]
	var config = ConfigFile.new()
	config.load("res://data/maps/" + filename + "/" + filename + ".ini")
	level_name = config.get_value("level", "name")
	description = config.get_value("level", "description")
	coins_total = config.get_value("level", "coins_total")
	coins_required = config.get_value("level", "coins_required")
	music = config.get_value("level", "music")
	#game_time_max = config.get_value("level", "game_time_max")
	Developer.print_verbose("Reading level information " + filename + ".ini.")
	return {"name": name,
			"description": description,
			"coins_total": coins_total,
			"coins_required": coins_required,
			"music": music,
			"game_time_max": game_time_max}

