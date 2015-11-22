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

func handle_menu_change(new_menu):
	# If there is no menu opened, there is no menu to hide
	if current_menu != null:
		get_node(current_menu).hide()
	get_node(new_menu).show()
	current_menu = new_menu

func setup_shadow_type_optionbutton():
	shadow_type_optionbutton = get_node("OptionsMenu/OptionsPanel/ShadowType/OptionButton")
	shadow_type_optionbutton.add_item(tr("ShadowsNone"))	# 0
	shadow_type_optionbutton.add_item(tr("ShadowsPCF5"))	# 1
	shadow_type_optionbutton.add_item(tr("ShadowsPCF13"))	# 2
	shadow_type_optionbutton.add_item(tr("ShadowsESM"))		# 3

	shadow_type_optionbutton.select(options.get("renderer", "shadow_type"))

func hide_all_menus():
	for node in get_tree().get_nodes_in_group("Menu"):
		node.hide()

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
	setup_shadow_type_optionbutton()

func _on_PlayButton_pressed():
	handle_menu_change("PlayMenu")

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_FPSLimit_enter_tree():
	options = get_node("/root/Options")
	get_node("OptionsMenu/OptionsPanel/FPSLimit/LineEdit").set_text(str(options.get("renderer", "fps_max")))
	OS.set_target_fps(options.get("renderer", "fps_max"))

func _on_FPSLimit_text_changed(text):
	# Prevent too low FPS limit
	if int(text) < 10:
		OS.set_target_fps(10)
		options.set("renderer", "fps_max", 10)
	else:
		OS.set_target_fps(int(text))
		options.set("renderer", "fps_max", int(text))

func _on_OptionsButton_pressed():
	handle_menu_change("OptionsMenu")

func _on_HelpButton_pressed():
	handle_menu_change("HelpMenu")

func _on_ShadowType_item_selected(ID):
	Globals.set("rasterizer/shadow_filter", ID)
	options.set("renderer", "shadow_type", ID)
	
func _on_MouseSensitivity_enter_tree():
	get_node("OptionsMenu/OptionsPanel/MouseSensitivity/HSlider").set_value(options.get("input", "view_sensitivity"))
	get_node("/root/Global").view_sensitivity = options.get("input", "view_sensitivity")

func _on_MouseSensitivity_value_changed(value):
	global.view_sensitivity = value
	options.set("input", "view_sensitivity", value)

func _on_ShadowType_enter_tree():
	Globals.set("rasterizer/shadow_filter", options.get("renderer", "shadow_type"))
