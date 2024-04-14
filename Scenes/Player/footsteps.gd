extends Node3D

@export var footstep_sounds :Array[AudioStreamWAV]
@onready var player :CharacterBody3D = get_parent()

func _ready():
	player.step.connect(play_sound)
	

func play_sound():
	var audio_player :AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	audio_player.stream = footstep_sounds[0]

	audio_player.pitch_scale = randf_range(0.8,1.1)
	add_child(audio_player)
	audio_player.play()
	print("step")
	#audio_player.finished.connect(func destroy(): audio_player.queue_free())
