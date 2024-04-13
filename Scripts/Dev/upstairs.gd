extends Node3D

const FLOOR_SCENE = preload ("res://Scenes/Dev/upstairs_floor.tscn")

@onready var player = get_node("Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if player.looking_at_mannequin():

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		input_dir = -input_dir
		var direction = (player.neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		$floors.position += direction * .1