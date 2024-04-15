extends CanvasLayer

var finger_intact = true
@onready var house_ext_tele = get_node("SubViewportContainer/SubViewport/Tbtest/house_ext_tele")
@onready var house_int_tele = get_node("SubViewportContainer/SubViewport/house_interior/house_int_tele")
@onready var boathouse_ext_tele = get_node("SubViewportContainer/SubViewport/boathouse/boathouse_ext_tele")
@onready var boathouse_int_tele = get_node("SubViewportContainer/SubViewport/boathouse_int/boathouse_int_tele")

func set_finger_intact(finger: bool) -> bool:
	finger_intact = finger
	return true

func get_finger_intact() -> bool:
	return finger_intact

func get_tele_node(node_name: String) -> Node:
	# get the node to teleport to when going through doors
	# we can also use this to handle scene transitions
	if node_name == "house_ext_tele":
		get_node("SubViewportContainer/SubViewport/Tbtest/WorldEnvironment").environment.volumetric_fog_density = 0.1
		return house_ext_tele
	if node_name == "house_int_tele":
		get_node("SubViewportContainer/SubViewport/Tbtest/WorldEnvironment").environment.volumetric_fog_density = 0.3
		return house_int_tele
	if node_name == "boathouse_ext_tele":
		return boathouse_ext_tele
	if node_name == "boathouse_int_tele":
		return boathouse_int_tele
	return null
