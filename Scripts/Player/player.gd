extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

#bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

var holding_heart: bool = false
var holding_face: bool = false
var holding_necklace: bool = false

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var neck := $Neck
@onready var camera := $Neck/Camera3d
# @onready var shader = get_tree().root.get_node("CanvasLayer/PostProcessing").get_material()
@onready var mannequin = get_tree().root.get_node_or_null("CanvasLayer/SubViewportContainer/SubViewport/Tbtest/mannequin")
@onready var shadow = get_tree().root.get_node_or_null("CanvasLayer/SubViewportContainer/SubViewport/Tbtest/shadow")
@onready var heart_guy = get_tree().root.get_node_or_null("CanvasLayer/SubViewportContainer/SubViewport/Tbtest/heart_guy")
@onready var arms = get_node("Neck/Player_Arms")
@onready var interact = get_tree().root.get_node_or_null("CanvasLayer/interact")
@onready var interact_cut = get_tree().root.get_node_or_null("CanvasLayer/interact_cut")
@onready var global = get_tree().root.get_node("CanvasLayer")

var can_play: bool = false
signal step

var can_interact = true
var can_walk = true

func looking_at_mannequin() -> bool:
	if mannequin:
		if mannequin.active:
			if global_position.distance_to(mannequin.global_position) < 30:
				return mannequin.get_node("VisibleOnScreenNotifier3D").is_on_screen()
		else: return false
	return false

func can_move() -> bool:
	return !looking_at_mannequin()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("interact")&&can_interact:
		if %interactable_raycast.is_colliding():
			var collider = %interactable_raycast.get_collider()
			if collider.is_in_group("interactables"):
				if collider.is_in_group("doors"):
					var tele_node = await global.get_tele_node(collider.get_meta("tele_loc"))
					if tele_node:
						position = tele_node.global_position
				if collider.is_in_group("body"):
					global.interact_body()
				if collider.is_in_group("wall"):
					global.interact_mass()
				if collider.is_in_group("axe"):
					global.interact_axe(self)
				if collider.is_in_group("heart_guy"):
					pickup_heart()
				if collider.is_in_group("mannequin"):
					pickup_necklace()
				if collider.is_in_group("face"):
					pickup_face()
				
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion and can_walk:
			neck.rotate_y( - event.relative.x * 0.01)
			camera.rotate_x( - event.relative.y * 0.01)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad( - 30), deg_to_rad(60))

func _process(delta: float) -> void:
	if mannequin:
		if mannequin.active:
			global.set_distortion(clamp(10.0 - global_position.distance_to(mannequin.global_position), 1.0, 10.0), "mannequin")
		else:
			global.set_distortion(1.0, "mannequin")
	if heart_guy:
		if heart_guy.active:
			global.set_distortion(clamp(15.0 - global_position.distance_to(heart_guy.global_position), 1.0, 15.0), "heart_guy")
		else:
			global.set_distortion(1.0, "heart_guy")
	if shadow: global.set_distortion(
		clamp(
			(10.0 - global_position.distance_to(shadow.global_position)) *
			remap(shadow.get_node("Timer").time_left, 2, 0, 1, 0),
			1.0, 10.0),
			"shadow")
	if %interactable_raycast.is_colliding():
		if %interactable_raycast.get_collider().is_in_group("interactables")&&can_interact:
			if global.get_finger_intact():
				if interact:
					interact.visible = true
			else:
				if interact_cut:
					interact_cut.visible = true
	else:
		if interact:
			interact.visible = false
		if interact_cut:
			interact_cut.visible = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# print(can_move())
	
	# Head bob
	if not looking_at_mannequin():
		t_bob += delta * velocity.length() * float(is_on_floor())
	elif looking_at_mannequin():
		print(Input.get_action_strength("forward"))
		t_bob += delta * Input.get_action_strength("forward") * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	if can_move() and can_walk:

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
	elif looking_at_mannequin()&&mannequin.active:
		var dist_to_man: float = global_position.distance_to(get_tree().root.get_node("CanvasLayer/SubViewportContainer/SubViewport/Tbtest/mannequin").global_position)
		var backforce_multiplyer = remap(dist_to_man, 0, 30., 1., 0)
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		input_dir = -input_dir
		var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED * 0.1 * backforce_multiplyer
			velocity.z = direction.z * SPEED * 0.1 * backforce_multiplyer
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	
	var low_pos = BOB_AMP - 0.05
	
	if pos.y > - low_pos:
		can_play = true
	
	if pos.y < - low_pos and can_play:
		can_play = false
		emit_signal("step")
	
	return pos

func on_item_returned():
	get_node("Neck/heart").visible = false
	get_node("Neck/necklace").visible = false
	get_node("Neck/face").visible = false
	arms.visible = false
	holding_heart = false
	holding_face = false
	holding_necklace = false

func pickup_heart():
	get_node("Neck/heart").visible = true
	heart_guy.deactivate()
	arms.visible = true
	holding_heart = true

func pickup_necklace():
	get_node("Neck/necklace").visible = true
	mannequin.deactivate()
	arms.visible = true
	holding_necklace = true

func pickup_face():
	get_node("Neck/face").visible = true
	arms.visible = true
	holding_face = true

func _on_level_changed_flood():
	$Neck/heart_spawn.position.z = 30
