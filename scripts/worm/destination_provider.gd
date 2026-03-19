class_name DestinationProvider 
extends Node
## Creates and output (provides) a new destination point for a worm

## Emitted when a new destination has been found 
signal new_point( point: Vector3 )

## Emitted when the boost speed is activated
signal boost_speed( on: bool )


func _process(_delta: float) -> void:
	compute_destination_point()
	
	
func compute_destination_point() -> void:
	pass
