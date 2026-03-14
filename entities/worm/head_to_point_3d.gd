class_name HeadToPoint3D 
extends Node

@export var motion_source: CharacterBody3D
@export var transform_source: Node3D

@export var destination_point: Vector3
@export var target: CharacterBody3D


func _ready() -> void:
	if target == null:
		target = get_parent()
		

func _physics_process(delta: float) -> void:
	if ( destination_point - target.global_position).length() > 0.1:
		destination_point.y = target.global_position.y
		target.look_at(destination_point)

		var direction = target.transform.basis.z.normalized()
		direction.y = 0
		target.velocity = direction * -target.speed
		target.move_and_slide()
	#print(motion_source.global_position)
