extends Node3D

@export var local_distortion = 1.0
var cutscene_started = false

signal endgame_distortion(d_amount)

func begin_cutscene(player, endgame_cam):
	cutscene_started = true
	player.camera.current = false
	endgame_cam.current = true
	player.can_walk = false
	get_tree().root.get_node("CanvasLayer").D_MULTIPLY = 30.0
	$AnimationPlayer.play("end_cutscene")

func _process(delta):
	if cutscene_started:
		endgame_distortion.emit(local_distortion)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "end_cutscene":
		get_tree().quit()
