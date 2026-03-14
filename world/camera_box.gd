class_name CameraBox
extends Node3D
##

static var world_camera: Camera3D = null

@export var main_worm: WormHeadCube

@onready var camera_3d_2: Camera3D = $Camera3D2


func _ready() -> void:
	world_camera = camera_3d_2
	

func _physics_process(delta: float) -> void:
	global_position = main_worm.global_position 
