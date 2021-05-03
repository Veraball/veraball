extends Control

onready var hud_scene = get_node("/root/Game/HUD")
onready var centerprint_scene = get_node("/root/Game/CenterPrint")

var fps_max
var shadow_type
var view_sensitivity

var current_menu


func _ready():
	hide_all_menus()

	# Hide HUD in main menu.
	hud_scene.hide()
	centerprint_scene.hide()
	Game.coins = 0
	Game.clock_running = true

	Options.init()


func handle_menu_change(new_menu):
	# If there is no menu opened, there is no menu to hide.
	if current_menu != null:
		get_node(current_menu).hide()
	get_node(new_menu).show()
	current_menu = new_menu


func hide_all_menus():
	for node in get_tree().get_nodes_in_group("Menu"):
		node.hide()


func _on_PlayButton_pressed():
	handle_menu_change("PlayMenu")


func _on_OptionsButton_pressed():
	handle_menu_change("OptionsMenu")


func _on_HelpButton_pressed():
	handle_menu_change("HelpMenu")


func _on_QuitButton_pressed():
	get_tree().quit()
