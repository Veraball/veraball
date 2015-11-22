extends Node

var coins = 0
var coins_total = 0
var coins_required = 0
var game_time = 0.0
var clock_running = true

var view_sensitivity = 0.25

func _ready():
	OS.set_window_size(Vector2(1024, 600))
	set_fixed_process(true)
	set_process_input(true)

	# Add HUD
	var hud_scene = preload("res://data/scenes/hud.xscn")
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

func _fixed_process(delta):
	if clock_running:
		game_time += delta

func centerprint(text):
	get_node("/root/Global/CenterPrint").show()
	get_node("/root/Global/CenterPrint/RichTextLabel").set_bbcode("[center]" + tr(text) + "[/center]")
	get_node("/root/Global/CenterPrint/AnimationPlayer").play("Fade")

func reset_game_state():
	get_tree().reload_current_scene()
	coins = 0
	game_time = 0
	clock_running = true

func is_in_main_menu():
	if get_tree().get_current_scene().get_filename() == "res://data/scenes/menu/main.xscn":
		return true
	else:
		return false

func pause_game():
	if get_tree().is_paused():
		get_tree().set_pause(false)
	else:
		get_tree().set_pause(true)

func start_game(level):
	get_tree().change_scene("res://data/maps/" + level + "/" + level + ".xscn")
	get_node("/root/Global/HUD").show()
	game_time = 0

func restart_level():
	reset_game_state()

func go_to_main_menu():
	get_tree().change_scene("res://data/scenes/menu/main.xscn")
	clock_running = true
	game_time = 0
	get_node("/root/Global/HUD").hide()
	get_node("/root/Global/CenterPrint").hide()