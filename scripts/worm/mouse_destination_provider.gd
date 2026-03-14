class_name MouseDestinationProvider extends DestinationPointProvider

var new_destination: Vector2
var set_destination: bool = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			new_destination =  get_viewport().get_screen_transform().affine_inverse() * event.position
			set_destination = true
			
			
func compute_destination_point() -> void:
	if set_destination:
		new_point.emit(new_destination)
		set_destination = false
