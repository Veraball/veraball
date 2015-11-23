extends Control

var global
var levels
var selected_level
var title

func init_level_list():
	for level in levels.list:
		get_node("PlayPanel/OptionButton").add_item(level[0])

func _ready():
	global = get_node("/root/Global")
	levels = get_node("/root/Levels")
	title = global.make_title("Play")
	get_node("PlayPanel/RichTextLabel").set_bbcode(title)
	# Select the first level in the list automatically
	selected_level = 0
	init_level_list()

func _on_Button_pressed():
	global.start_game(selected_level)

func _on_OptionButton_item_selected(ID):
	selected_level = ID
