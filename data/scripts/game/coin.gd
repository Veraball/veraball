extends Spatial

var picked = false


func _on_Area_body_enter(_body: Node):
	if not picked:
		get_node("AnimationPlayer").play("Pickup")
		picked = true
		Game.coins += 1
