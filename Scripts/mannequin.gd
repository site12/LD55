extends Node3D

var active = true

func activate():
	active = true
	$OmniLight3D3.visible = true
	$OmniLight3D4.visible = true

func deactivate():
	active = false
	$OmniLight3D3.visible = false
	$OmniLight3D4.visible = false