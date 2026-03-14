class_name WormHeadCube extends CharacterBody2D

@export var base_speed: float = 50
@export var full_rotation_speed: float = 2.5

@onready var destination_sync: DestinationSync = $DestinationSync
@onready var target_rotation: float = rotation
@onready var turn_speed: float = full_rotation_speed
@onready var speed: float = base_speed


func _physics_process(delta: float) -> void:
	target_rotation = global_position.angle_to_point( destination_sync.destination )
	rotation = rotate_toward(rotation, target_rotation, turn_speed * delta)
	
	#target_line_2d.points = [global_position, target_point]
	#angle_line_2d.points = [global_position, global_position + (Vector2(cos(target_rotation),sin(target_rotation)) * 50)]
	
	velocity = transform.x * speed
	move_and_slide()
