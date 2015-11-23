extends Control

var global
var title

var text = "[color=#ffff00]" + tr("HelpControlsTitle") + "[/color]" + "\n\n" \
+ tr("HelpControlTheBall") + "\n" \
+ tr("HelpJump")

func _ready():
	global = get_node("/root/Global")
	title = global.make_title("Help")
	get_node("HelpPanel/Title").set_bbcode(title)
	get_node("HelpPanel/Text").set_bbcode(text)
