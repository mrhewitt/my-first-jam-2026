class_name CameraBox
extends Node3D
##

## Primary camera, can be accessed by anyone wanting camera info
static var world_camera: Camera3D = null

## Set to the worm head that the camera must follow
@export var worm_to_follow: WormHeadCube

@onready var camera_3d_2: Camera3D = $Camera3D2


func _ready() -> void:
	# Make a ref to our camera so other nodes in the world can essily access camera setup
	world_camera = camera_3d_2


func _physics_process(delta: float) -> void:
	global_position = worm_to_follow.global_position 
