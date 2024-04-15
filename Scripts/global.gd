# Heart by Poly by Google [CC-BY] via Poly Pizza

extends CanvasLayer

const D_MULTIPLY: float = 8.0

var body_interacted: bool = false
var finger_intact: bool = true
var face_returned: bool = false
var necklace_returned: bool = false
var heart_returned: bool = false

var player_indoors: bool = false

# Distortion var for shader; min = 1.0; max = 10.0
var distortion: float = 1.0
var distortion_source: String = ""

@onready var shader = get_node("PostProcessing").get_material()

@onready var house_ext_tele = get_node("SubViewportContainer/SubViewport/Tbtest/house/house_ext_tele")
@onready var house_int_tele = get_node("SubViewportContainer/SubViewport/house_interior/house_int_tele")
@onready var boathouse_ext_tele = get_node("SubViewportContainer/SubViewport/boathouse/boathouse_ext_tele")
@onready var boathouse_int_tele = get_node("SubViewportContainer/SubViewport/boathouse_int/boathouse_int_tele")
@onready var heart_guy = get_node_or_null("SubViewportContainer/SubViewport/Tbtest/heart_guy")
@onready var shadow = get_node_or_null("SubViewportContainer/SubViewport/Tbtest/shadow")
@onready var mass_lights = get_node_or_null("SubViewportContainer/SubViewport/house_interior/basement_misc/Mass/light_pivot")
@onready var player = get_node_or_null("SubViewportContainer/SubViewport/Tbtest/Player")

signal level_changed_flood
signal item_returned

func set_distortion(d_level: float, d_source: String) -> void:
	if d_level > distortion:
		distortion = d_level
		distortion_source = d_source
	else:
		if d_source == distortion_source:
			distortion = d_level
	var scaled_distortion = remap(distortion, 1., 10., 1., D_MULTIPLY)
	shader.set_shader_parameter("distortion", scaled_distortion)
	shader.set_shader_parameter("low_distortion", remap(scaled_distortion, 1., 10., 1., 2.))
	shader.set_shader_parameter("high_distortion", remap(scaled_distortion, 1., 10., 1., 100.))

func set_finger_intact(finger: bool) -> bool:
	finger_intact = finger
	return true

func set_heartguy_active(state: bool) -> void:
	if heart_guy:
		heart_guy.active = state
		heart_guy.visible = state
		if state == true:
			heart_guy.spawn()

func set_shadow_active(state: bool) -> void:
	if shadow:
		shadow.active = state
		shadow.visible = state
		if state == true:
			shadow.find_new_location()

func get_finger_intact() -> bool:
	return finger_intact

func get_tele_node(node_name: String) -> Node:
	# get the node to teleport to when going through doors
	# we can also use this to handle scene transitions
	if node_name == "house_ext_tele":
		# Lock player in house if they haven't interacted with body
		if body_interacted:
			play_sound(load("res://Sounds/door_open.wav"))
			get_node("SubViewportContainer/SubViewport/Tbtest/WorldEnvironment").environment.volumetric_fog_density = 0.1
			# Just check that we got the node succesfully
			set_heartguy_active(true)
			set_shadow_active(true)
			if face_returned&&necklace_returned:
				_scene_change_flood()
			player_indoors = false
			return house_ext_tele
		else:
			play_sound(load("res://Sounds/door_locked.wav"))
			return null
	if node_name == "house_int_tele":
		play_sound(load("res://Sounds/door_open.wav"))
		get_node("SubViewportContainer/SubViewport/Tbtest/WorldEnvironment").environment.volumetric_fog_density = 0.3
		player_indoors = true
		set_heartguy_active(false)
		set_shadow_active(false)
		return house_int_tele
	if node_name == "boathouse_ext_tele":
		play_sound(load("res://Sounds/door_open.wav"))
		player_indoors = false
		set_heartguy_active(true)
		set_shadow_active(true)
		return boathouse_ext_tele
	if node_name == "boathouse_int_tele":
		play_sound(load("res://Sounds/door_open.wav"))
		player_indoors = true
		set_heartguy_active(false)
		set_shadow_active(false)
		return boathouse_int_tele
	return null

func _ready():
	if heart_guy:
		connect("level_changed_flood", heart_guy._on_level_changed_flood)

func _scene_change_flood():
	get_node("SubViewportContainer/SubViewport/Tbtest/WorldEnvironment").environment = load('res://Scenes/Dev/flood_env.tres')
	get_node("SubViewportContainer/SubViewport/Tbtest/DirectionalLight3D").light_color = Color.LIGHT_CORAL
	get_node("SubViewportContainer/SubViewport/Tbtest/DirectionalLight3D").light_energy = 0.5
	get_node("SubViewportContainer/SubViewport/Tbtest/Flood").visible = true
	level_changed_flood.emit()

func play_sound(sound: AudioStreamWAV):
	var audio_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	audio_player.stream = sound

	audio_player.pitch_scale = randf_range(1, 1.05)
	get_tree().get_root().add_child.call_deferred(audio_player)
	await get_tree().create_timer(0.1).timeout
	audio_player.play()
	audio_player.finished.connect(func destroy(): audio_player.queue_free())

func interact_body():
	if finger_intact&&!face_returned&&!necklace_returned&&!heart_returned:
		if !player.holding_heart&&!player.holding_face&&!player.holding_necklace:
			%body_text.text = "She can't talk right now."
			%body_anims.play("fade")
			%Player.can_interact = false
			%Player.can_walk = false
			%interact.visible = false
			%interact_cut.visible = false
			if mass_lights:
				mass_lights.visible = true
			await get_tree().create_timer(5).timeout
			%Player.can_interact = true
			%Player.can_walk = true
			%house_interior.get_node("basement_misc/Mass/mass_collider/mass_col").disabled = false
	# Return items to body
	if player.holding_necklace:
		necklace_returned = true
		player.on_item_returned()
		get_node("SubViewportContainer/SubViewport/house_interior/woman2/necklace").visible = true
	elif player.holding_face:
		face_returned = true
		player.on_item_returned()
		get_node("SubViewportContainer/SubViewport/house_interior/woman2/face").visible = true
	elif player.holding_heart:
		heart_returned = true
		player.on_item_returned()

func interact_mass():
	if finger_intact&&!face_returned&&!necklace_returned&&!heart_returned:
		body_interacted = true
		%body_text.text = "YOU'RE IN DIRE STRAITS, AREN'T YOU?"
		%body_anims.play("fade")
		%Player.can_interact = false
		%Player.can_walk = false
		%interact.visible = false
		%interact_cut.visible = false
		await get_tree().create_timer(5).timeout
		%body_anims.stop()
		%body_text.text = "THE BODY IS RESTING. YOU CAN WAKE IT."
		%body_anims.play("fade")
		await get_tree().create_timer(5).timeout
		%body_anims.stop()
		%body_text.text = "YOU MUST STEAL BACK HER SMILE,"
		%body_anims.play("fade")
		await get_tree().create_timer(5).timeout
		%body_anims.stop()
		%body_text.text = "FIND THE METAL NOOSE,"
		%body_anims.play("fade")
		await get_tree().create_timer(5).timeout
		%body_anims.stop()
		%body_text.text = "AND WIN BACK HER HEART."
		%body_anims.play("fade")
		await get_tree().create_timer(5).timeout
		%Player.can_interact = true
		%Player.can_walk = true

func interact_axe(player):
	if finger_intact&&!face_returned&&!heart_returned:
		%interact.visible = false
		%interact_cut.visible = false
		%Player.can_interact = false
		%body_anims.play("fully_fade")
		await get_tree().create_timer(0.5).timeout
		%boathouse_int.begin_cutscene(player,%boathouse_cam)
		await get_tree().create_timer(6.5).timeout
		%body_anims.stop()
		%body_anims.play("fully_fade")
		await get_tree().create_timer(0.5).timeout
		%Player.camera.current = true
		%Player.can_interact = true
		%Player.can_walk = true
		finger_intact = false
		

		
		
