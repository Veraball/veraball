extends Control

var title = "[color=#ffff00][center][b]" + tr("Options") + "[/b][/center][/color]"

func _ready():
	get_node("OptionsPanel/Title").set_bbcode(title)
