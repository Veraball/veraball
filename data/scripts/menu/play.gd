extends Control

var global
var selected_level

var levels = [
	#["Full Name", "filename"],
	["Basics", "basics"],
	["Advanced Basics", "basics-2"]
]

func init_level_list():
	for level in levels:
		get_node("PlayPanel/OptionButton").add_item(level[0])

func _ready():
	global = get_node("/root/Global")
	# Select the first level in the list automatically
	selected_level = 0
	init_level_list()

func _on_Button_pressed():
	global.start_game(levels[selected_level][1])

func _on_OptionButton_item_selected(ID):
	selected_level = ID
