class_name CameraBox
extends Node3D
##

## Myself as a preload for spawning instances via CameraBox.instance(...)
const SELF_SCENE = preload("uid://ibhj2qh57jnt")

## Primary camera, can be accessed by anyone wanting camera info
static var world_camera: Camera3D = null

## Set to the worm head that the camera must follow
@export var worm_to_follow: WormHeadCube

@onready var camera_3d_2: Camera3D = $Camera3D2


func _ready() -> void:
	# Make a ref to our camera so other nodes in the world can essily access camera setup
	world_camera = camera_3d_2


func _physics_process(_delta: float) -> void:
	global_position = worm_to_follow.global_position 
	
	
## create a CameraBox instance
## [param follow] Player WormHeadCube to attach the camera to
static func instance( follow: WormHeadCube ) -> CameraBox:
	var self_instance: CameraBox = SELF_SCENE.instantiate()
	self_instance.worm_to_follow = follow
	return self_instance
