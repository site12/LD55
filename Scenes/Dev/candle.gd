extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	await get_tree().create_timer(randf_range(0.1,1)).timeout
	$AnimationPlayer.play("candle_light")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
