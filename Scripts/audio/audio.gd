extends Node2D

var tracks:Array[AudioStreamWAV] = [load("res://Sounds/compressed/ambience (1).wav")]
@export var locations:Array[Marker3D]
@onready var player :CharacterBody3D = %Player

var track_objects = []

func _ready():
	
	for x in tracks:
		play_sound(x)
	


func _process(delta):
	for x in track_objects:
		if x == track_objects[0]:
			#x.volume_db = player.position.distance_to(locations[0].position)
			pass
		

func play_sound(sound:AudioStreamWAV):
	var audio_player :AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	audio_player.stream = sound

	audio_player.pitch_scale = randf_range(1,1.05)
	track_objects.append(audio_player)
	get_tree().get_root().add_child.call_deferred(audio_player)
	await get_tree().create_timer(0.1).timeout
	audio_player.play()
	audio_player.finished.connect(func repeat(): audio_player.play())
