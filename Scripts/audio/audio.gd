extends Node2D

var tracks:Array[AudioStreamWAV] = [
	load("res://Sounds/compressed/ambience (1).wav"),
	load("res://Sounds/compressed/VHS_damage.wav"),
	load("res://Sounds/compressed/water.wav")
	]
@export var locations:Array[Marker3D]
@onready var player :CharacterBody3D = %Player
@onready var global = get_tree().root.get_node("CanvasLayer")

var track_objects = []

var flooded = false

func _ready():
	global.level_changed_flood.connect(flood)
	for x in tracks:
		play_sound(x)
	
func flood():
	flooded = true

func _process(delta):
	for x in track_objects:
		if x == track_objects[2]:
			if flooded && !global.player_indoors:
				x.volume_db = 0
			else:
				x.volume_db = -100
		

func play_sound(sound:AudioStreamWAV):
	var audio_player :AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	audio_player.stream = sound

	audio_player.pitch_scale = randf_range(1,1.05)
	track_objects.append(audio_player)
	get_tree().get_root().add_child.call_deferred(audio_player)
	await get_tree().create_timer(0.1).timeout
	audio_player.play()
	audio_player.finished.connect(func repeat(): audio_player.play())
