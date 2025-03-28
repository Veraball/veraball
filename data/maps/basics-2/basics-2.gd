extends Node3D


func _on_Reset_body_enter(_body: Node):
	Game.player_fall_out()
