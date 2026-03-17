class_name AiProvider 
extends DestinationProvider

enum NavigationState { COLLECTING_CUBE, WANDERING, NOT_STARTED }

var has_run: bool = false
var last_target_point: Vector3

var navigation_agent: NavigationAgent3D
var state: NavigationState = NavigationState.NOT_STARTED
var worm_head: WormHeadCube


func _ready() -> void:
	worm_head = get_parent()
	navigation_agent = NavigationAgent3D.new()
	# when navigation is finished go back to empty state for next process frame to find a new target
	navigation_agent.navigation_finished.connect( _navigation_complete )
	#navigation_agent.target_reached.connect( _goto_next_point )
	
	navigation_agent.target_desired_distance = 0.1
	navigation_agent.path_desired_distance = 0.1
	
	worm_head.add_child.call_deferred(navigation_agent)
	
	
func _physics_process(_delta: float) -> void:
	if state != NavigationState.NOT_STARTED:
		_goto_next_point()

	
func compute_destination_point() -> void:
	# look and see if any blocks are near by, go there if so
	if state == NavigationState.WANDERING or state == NavigationState.NOT_STARTED:
		var target_cube: StationaryCube = null
		for cube in get_tree().get_nodes_in_group(Groups.CUBE_GROUP):
			if cube.grow_value <= worm_head.grow_value and (cube.global_position - worm_head.global_position).length() < 5:
				if target_cube == null or target_cube.grow_value < cube.grow_value:
					target_cube = cube	
		
		if target_cube:
			navigate_to(target_cube.global_position)
			print("Going to cube at ", target_cube.global_position)
			state = NavigationState.COLLECTING_CUBE
			return
			
	# if we have no start, pick out first point to go to
	if state == NavigationState.NOT_STARTED:
		navigate_to( _pick_new_target()	)
		
		
func navigate_to( point: Vector3 ) -> void:
	point.y = 0.5
	navigation_agent.target_position = point
	var next_agent_point = navigation_agent.get_next_path_position()
	next_agent_point.y = point.y
	
	# if point selected it right on me its possible we cannot get to target so pick again
	if (next_agent_point - worm_head.global_position).length() < 0.1:
		state = NavigationState.NOT_STARTED
	else:
		print("Navigate to ", next_agent_point)
		new_point.emit( next_agent_point )	

	
func _goto_next_point() -> void:
	var next_point = navigation_agent.get_next_path_position()
	next_point.y = worm_head.global_position.y
	
	# if we are close to destination and have been so for a couple of frames
	# force it to move on, as it gets stuck sometimes and NavigationAgent does not contunue
	if (next_point - get_parent().global_position).length() < 0.1:
		print( get_parent().name, " resetting navigation ")
		next_point = get_parent().global_position
		state = NavigationState.NOT_STARTED
	
	if last_target_point != next_point:
		new_point.emit( next_point )
		last_target_point = next_point


func _pick_new_target() -> Vector3:
	state = NavigationState.WANDERING
	return Vector3( randf_range(-45,45), worm_head.global_position.y, randf_range(-45,45) )


func _navigation_complete() -> void:
	state = NavigationState.NOT_STARTED 
