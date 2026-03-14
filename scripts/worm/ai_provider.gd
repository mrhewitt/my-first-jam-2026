class_name AiProvider 
extends DestinationProvider

var has_run: bool = false
var target_point: Vector3

func compute_destination_point() -> void:
	if (get_parent().global_position - target_point).length() < 4:
		target_point = Vector3( randf_range(-45,45), 0, randf_range(-45,45) )
		new_point.emit( target_point )
		#has_run = true
