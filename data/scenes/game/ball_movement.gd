extends RigidBody3D


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# Pass to the parent so we can run the function there.
	get_parent().integrate_forces(state)
