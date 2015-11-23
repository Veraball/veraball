extends Spatial

var global

var picked = false

func _ready():
	global = get_node("/root/Global")

func _on_Area_body_enter(body):
	if not picked:
		get_node("AnimationPlayer").play("Pickup")
		picked = true
		global.coins += 1