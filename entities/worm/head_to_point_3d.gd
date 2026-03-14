class_name HeadToPoint3D 
extends Node

@export var motion_source: CharacterBody3D
@export var transform_source: Node3D

@export var destination_point: Vector3

#var target_rotation:

func _physics_process(delta: float) -> void:
	destination_point.y = transform_source.global_position.y
	transform_source.look_at(destination_point)

	var direction = transform_source.transform.basis.z.normalized()
	direction.y = 0
	motion_source.velocity = direction * -3
	motion_source.move_and_slide()
	#print(motion_source.global_position)
