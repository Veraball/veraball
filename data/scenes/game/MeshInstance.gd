extends MeshInstance


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func _process(_delta):
	var ss = MeshInstance.new()
	ss.set_mesh(SphereMesh.new())
	ss.create_debug_tangents()
