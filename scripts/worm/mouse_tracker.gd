class_name MouseTracker extends DestinationProvider

@export var camera: Camera3D

var last_point: Vector3
var plane: Plane 


func _ready() -> void:
	if camera == null:
		camera = CameraBox.world_camera
	plane = Plane(Vector3.UP)


func compute_destination_point() -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_start := camera.project_ray_origin(mouse_pos)
	var ray_direction := camera.project_ray_normal(mouse_pos)
	
	var intersection = plane.intersects_ray(ray_start, ray_direction)
	if intersection and (intersection - last_point).length() > 0.2:
		last_point = intersection
		new_point.emit(intersection)
