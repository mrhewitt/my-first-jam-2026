class_name WormHeadCube
extends WormSegment
##


@onready var head_to_point_3d: Node = $HeadToPoint3D
@onready var mouse_tracker: MouseTracker = $MouseTracker


func _ready() -> void:
	super()
	mouse_tracker.new_point.connect( func(p): head_to_point_3d.destination_point = p )


func consume_cube( cube: StationaryCube ) -> bool:
	# only server 
	if cube.grow_value <= grow_value:
		add_cube(cube)
		return true
	else:
		return false
	
