extends Node3D


func begin_cutscene(player,boathouse_cam):
	player.camera.current = false
	boathouse_cam.current = true
	player.can_walk = false
