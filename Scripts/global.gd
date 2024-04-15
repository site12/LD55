extends CanvasLayer

const D_MULTIPLY = 8.0

var finger_intact = true

# Distortion var for shader; min = 1.0; max = 10.0
var distortion: float = 1.0
var distortion_source: String = ""

@onready var shader = get_node("PostProcessing").get_material()

@onready var house_ext_tele = get_node("SubViewportContainer/SubViewport/Tbtest/house_ext_tele")
@onready var house_int_tele = get_node("SubViewportContainer/SubViewport/house_interior/house_int_tele")
@onready var boathouse_ext_tele = get_node("SubViewportContainer/SubViewport/boathouse/boathouse_ext_tele")
@onready var boathouse_int_tele = get_node("SubViewportContainer/SubViewport/boathouse_int/boathouse_int_tele")

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

func get_finger_intact() -> bool:
	return finger_intact

func get_tele_node(node_name: String) -> Node:
	# get the node to teleport to when going through doors
	# we can also use this to handle scene transitions
	if node_name == "house_ext_tele":
		play_sound(preload("res://Sounds/door_open.wav"))
		get_node("SubViewportContainer/SubViewport/Tbtest/WorldEnvironment").environment.volumetric_fog_density = 0.1
		return house_ext_tele
	if node_name == "house_int_tele":
		play_sound(preload("res://Sounds/door_open.wav"))
		get_node("SubViewportContainer/SubViewport/Tbtest/WorldEnvironment").environment.volumetric_fog_density = 0.3
		return house_int_tele
	if node_name == "boathouse_ext_tele":
		play_sound(preload("res://Sounds/door_open.wav"))
		return boathouse_ext_tele
	if node_name == "boathouse_int_tele":
		play_sound(preload("res://Sounds/door_open.wav"))
		return boathouse_int_tele
	return null


func play_sound(sound:AudioStreamWAV):
	var audio_player :AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	audio_player.stream = sound

	audio_player.pitch_scale = randf_range(1,1.05)
	get_tree().get_root().add_child.call_deferred(audio_player)
	await get_tree().create_timer(0.1).timeout
	audio_player.play()
	audio_player.finished.connect(func destroy(): audio_player.queue_free())
