extends Control

var title
var text = "[color=#ffff00]" + tr("HelpControlsTitle") + "[/color]" + "\n\n" \
+ tr("HelpControlTheBall") + "\n" \
+ tr("HelpJump")

func _ready():
	title = Game.make_title("Help")
	get_node("HelpPanel/Title").set_bbcode(title)
	get_node("HelpPanel/Text").set_bbcode(text)
