extends Sprite3D

var shadow_seen: bool = false
const RESPAWN_RADIUS: float = 10.0
@onready var player = get_tree().root.get_node("CanvasLayer/SubViewportContainer/SubViewport/Tbtest/Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shadow_seen:
		modulate = Color(1, 1, 1, remap($Timer.time_left, $Timer.wait_time, 0, 1.0, 0))
	else:
		if player.global_position.distance_to(global_position) > 40.0:
			find_new_location()

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	print("on_screen")
	shadow_seen = true
	$Timer.start()

func find_new_location():
	shadow_seen = true
	var pos: Vector3 = player.global_position
	var theta: float = randf_range(0., 2 * PI)
	position.x = RESPAWN_RADIUS * cos(theta) + pos.x
	position.y = pos.y
	position.z = RESPAWN_RADIUS * sin(theta) + pos.z
	shadow_seen = false
	modulate = Color.WHITE

func _on_timer_timeout() -> void:
	position.y += 100.0
	$respawn_timer.wait_time = randf_range(5., 20.)
	$respawn_timer.start()

func _on_respawn_timer_timeout() -> void:
	find_new_location()
