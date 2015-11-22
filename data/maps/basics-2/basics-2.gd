extends Spatial

var global

func _ready():
	global = get_node("/root/Global")
	global.coins_total = 10
	global.coins_required = 10

func _on_Reset_body_enter(body):
	global.reset_game_state()
