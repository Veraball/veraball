extends Control

var global
var title

func _ready():
	global = get_node("/root/Global")
	title = global.make_title("Options")
	get_node("OptionsPanel/Title").set_bbcode(title)
