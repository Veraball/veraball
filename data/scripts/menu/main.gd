extends Control

var global
var options
var hud_scene
var centerprint_scene

# For setting up OptionButtons
var shadow_type_optionbutton

var fps_max
var shadow_type
var view_sensitivity

var current_menu

func _ready():
	global = get_node("/root/Global")
	options = get_node("/root/Options")
	hud_scene = get_node("/root/Global/HUD")
	centerprint_scene = get_node("/root/Global/CenterPrint")
	set_process_input(true)
	
	# Hide all menus
	hide_all_menus()
	
	# Hide HUD in main menu
	hud_scene.hide()
	centerprint_scene.hide()
	# Reset coin count to 0:
	global.coins = 0
	global.clock_running = true
	
	options.init()

func handle_menu_change(new_menu):
	# If there is no menu opened, there is no menu to hide
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
