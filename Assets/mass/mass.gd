extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%mass_anims.play("breateh")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$light_pivot.rotation.y += delta
