extends Node3D

@export var local_distortion = 1.0
var cutscene_started = false

signal boathouse_distortion(d_amount)

func begin_cutscene(player, boathouse_cam):
	cutscene_started = true
	player.camera.current = false
	boathouse_cam.current = true
	player.can_walk = false
	$AnimationPlayer.play("boathouse_cutscene")

func _process(delta):
	if cutscene_started:
		boathouse_distortion.emit(local_distortion)
