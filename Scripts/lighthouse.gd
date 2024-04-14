extends SpotLight3D

const FULL_ENERGY = 100

@onready var player = get_tree().root.get_node("CanvasLayer/SubViewportContainer/SubViewport/Tbtest/Player")
@onready var bear = get_tree().root.get_node("CanvasLayer/SubViewportContainer/SubViewport/Tbtest/bear")
var active = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active:
		rotation.y += 1 * delta

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		light_energy = FULL_ENERGY
		active = true
