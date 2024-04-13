extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var neck := $Neck
@onready var camera := $Neck/Camera3d

func looking_at_mannequin() -> bool:
	# var global_position = get_parent().get_node("mannequin")
	var threshold = .5
	# if rotation in range(global_position.angle_to(get_parent().get_node("mannequin").global_position) - threshold, global_position.angle_to(get_parent().get_node("mannequin").global_position) + threshold):
	# 	print("true")
	# 	return true
	# else:
	# 	print("false")
	# 	return false
	# print("angle:")
	# print(global_position.signed_angle_to(get_parent().get_node("mannequin").global_position))
	# print("rotation:")
	# print($Neck.rotation.y)
	return get_parent().get_node("mannequin").get_node("VisibleOnScreenNotifier3D").is_on_screen()

func can_move() -> bool:
	return !looking_at_mannequin()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y( - event.relative.x * 0.01)
			camera.rotate_x( - event.relative.y * 0.01)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad( - 30), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# print(can_move())
	if can_move():
		# Handle Jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		move_and_slide()
