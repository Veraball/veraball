extends Spatial

var global

func _ready():
	global = get_node("/root/Global")

func _on_Reset_body_enter(body):
	global.restart_level()
