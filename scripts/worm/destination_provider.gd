class_name DestinationProvider 
extends Node
## Creates and output (provides) a new destination point for a worm

## Emitted when a new destination has been found 
signal new_point( point: Vector3 )


func _process(_delta: float) -> void:
	compute_destination_point()
	
	
func compute_destination_point() -> void:
	pass
