extends Spatial

func _on_WelcomeToVeraball_body_enter(_body: Node) -> void:
	Game.centerprint("CenterPrintWelcomeToVeraball")


func _on_CollectAllTheCoins_body_enter(_body: Node) -> void:
	Game.centerprint("CenterPrintCollectAllTheCoins")


func _on_ReachTheGoal_body_enter(_body: Node) -> void:
	Game.centerprint("CenterPrintReachTheGoal")


func _on_Reset_body_enter(_body: Node) -> void:
	Game.player_fall_out()
