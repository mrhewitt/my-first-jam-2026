class_name MouseTracker extends Node3D

signal new_point( point: Vector3 ) 

@export var camera: Camera3D

var last_point: Vector3

func _process(delta: float) -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_start := camera.project_ray_origin(mouse_pos)
	var ray_direction := camera.project_ray_normal(mouse_pos)
	
	var plane := Plane(Vector3.UP)
	
	var intersection = plane.intersects_ray(ray_start, ray_direction)
	if intersection:
		#print("Mouse at ", intersection)
		new_point.emit(intersection)
	#var world3d = get_world_3d()
	#var space_state = world3d.direct_space_state
	#var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	#var result = space_state.intersect_ray(query)
	
	#if result.has('position') and result.position != last_point:
	#	print("Mouse at ", result.position)
	#	last_point = result.position
	#	new_point.emit(last_point)
