extends Control

var title = "[color=#ffff00][center][b]" + tr("Help") + "[/b][/center][/color]"

var text = "[color=#ffff00]" + tr("HelpControlsTitle") + "[/color]" + "\n\n" \
+ tr("HelpControlTheBall") + "\n" \
+ tr("HelpJump")

func _ready():
	get_node("HelpPanel/Title").set_bbcode(title)
	get_node("HelpPanel/Text").set_bbcode(text)
