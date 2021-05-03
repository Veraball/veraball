extends RigidBody


func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	# Pass to the parent so we can run the function there.
	get_parent().integrate_forces(state)
