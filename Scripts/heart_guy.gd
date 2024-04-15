extends Node3D

const SPEED_MAX: float = 10.0
const SPEED_MIN: float = 5.0
const SEEN_DISTANCE: float = 20.0
var fleeing: bool = false
var last_spawn: Vector3 = Vector3.ZERO
var speed: float = 10.0
var speed_mutiplyer: float = 1.0

@onready var player = get_tree().root.get_node("CanvasLayer/SubViewportContainer/SubViewport/Tbtest/Player")
@onready var spawn_point = player.get_node("Neck/heart_spawn")
@onready var target = player.get_node("Neck/heart_target")

func _ready() -> void:
	spawn()

func spawn() -> void:
	last_spawn = snapped(spawn_point.global_position, Vector3(0.1, 0.1, 0.1))
	position = last_spawn

func _on_level_changed_flood():
	speed_mutiplyer = 0.5

func _process(delta) -> void:
	# Check if entity is seen and run away
	if !fleeing&&$VisibleOnScreenNotifier3D.is_on_screen():
		if global_position.distance_to(player.global_position) < SEEN_DISTANCE:
			fleeing = true
	# Return to last spawn and pick a new spawn
	if snapped(global_position, Vector3(0.1, 0.1, 0.1)) == last_spawn:
		spawn()
		fleeing = false

	# Run towards target node if engaging and away if fleeing
	if !fleeing:
		speed = remap(global_position.distance_to(player.global_position), 80.0, 5.0, SPEED_MAX, SPEED_MIN)
		speed *= speed_mutiplyer
		position.x = move_toward(position.x, target.global_position.x, speed * delta)
		position.z = move_toward(position.z, target.global_position.z, speed * delta)
	else:
		speed = SPEED_MAX
		speed *= speed_mutiplyer
		position.x = move_toward(position.x, last_spawn.x, speed * delta)
		position.z = move_toward(position.z, last_spawn.z, speed * delta)

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	pass