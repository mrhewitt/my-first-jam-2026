class_name AiProvider 
extends DestinationProvider

enum NavigationState { COLLECTING_CUBE, WANDERING, NOT_STARTED }

var has_run: bool = false
var last_target_point: Vector3

var navigation_agent: NavigationAgent3D
var state: NavigationState = NavigationState.NOT_STARTED
var worm_head: WormHeadCube

## When a new target has been picked, we must check on next frame if its reachable
var do_reachable_check: bool = false

## Maintains a list of unreachable cubes as they cna be pushed/spawn just outside[br]
## edge of the navigation region bordering a wall
var unreachable_cubes: Array
var target_cube: StationaryCube = null

var debug: bool = false


func _ready() -> void:
	worm_head = get_parent()
	navigation_agent = NavigationAgent3D.new()
	# when navigation is finished go back to empty state for next process frame to find a new target
	navigation_agent.navigation_finished.connect( _navigation_complete )
	#navigation_agent.target_reached.connect( _goto_next_point )
	
	navigation_agent.target_desired_distance = 0.1
	navigation_agent.path_desired_distance = 0.1
	navigation_agent.use_3d_avoidance = false
	
	worm_head.add_child.call_deferred(navigation_agent)
	
	
func _physics_process(_delta: float) -> void:
	if do_reachable_check:
		# if we cannot get to our target set not started state and try again
		if not navigation_agent.is_target_reachable():
			# if we are navigating to a cube, add it to list of unreachables and try again
			if state == NavigationState.COLLECTING_CUBE:
				unreachable_cubes.append(target_cube)
				target_cube = null 
				
			state = NavigationState.NOT_STARTED
			if debug: print("%s invalid target " % get_parent().player_name, navigation_agent.target_position, " at ", get_parent().global_position, ", dist: ", (navigation_agent.target_position-get_parent().global_position).length())
			if debug: print( "Size ", worm_head.get_block_size(), " ; Y: ", worm_head.global_position.y )
		else:
			if debug: print("%s reachable target " %  get_parent().player_name,navigation_agent.target_position)
			if debug: print( "Size ", worm_head.get_block_size(), " ; Y: ", worm_head.global_position.y )
			pass
		do_reachable_check = false
	
	#	new_point.emit( next_agent_point )		
	if not do_reachable_check and state != NavigationState.NOT_STARTED:
		_goto_next_point()

	
func compute_destination_point() -> void:
	# look and see if any blocks are near by, go there if so
	if state == NavigationState.WANDERING or state == NavigationState.NOT_STARTED:
		target_cube = null
		var closest_distance: float = 99999.0
		for cube in get_tree().get_nodes_in_group(Groups.CUBE_GROUP):
			if cube.grow_value <= worm_head.grow_value and (cube.global_position - worm_head.global_position).length() < 5:
				# with in range, make sure its not in unreachable list, and if ok, go there if its first one we found or if
				# it is the closest one
				if not unreachable_cubes.has(cube):
					var distance_to_cube: float = (cube.global_position - worm_head.global_position).length()
					# goto first target found or goto a better target or go to smiliar target thats closer
					if target_cube == null or  \
					   cube.grow_value > target_cube.grow_value  or  \
					  (cube.grow_value == target_cube.grow_value and distance_to_cube < closest_distance):
						target_cube = cube	
						closest_distance = distance_to_cube
						
		if target_cube:
			# head to a position that is on cude X/Z my level with my y (so bigger worm heads dont try to dive into the ground
			var target_position := Vector3( target_cube.global_position.x, worm_head.global_position.y, target_cube.global_position.z)
			if debug: print( "%s (%s) Going to cube at " % [get_parent().name, get_parent().player_name], target_position)
			navigate_to(target_position)
			state = NavigationState.COLLECTING_CUBE
			return
			
	# if we have no start, pick out first point to go to
	if state == NavigationState.NOT_STARTED:
		navigate_to( _pick_new_target()	)
		
		
func navigate_to( point: Vector3 ) -> void:
	#point.y = 0.5
	navigation_agent.path_height_offset = 0.5 - worm_head.global_position.y
	navigation_agent.target_position = point
	if debug: print("%s navigating to " % worm_head.player_name, navigation_agent.target_position, " from ", worm_head.global_position, " dist:", (navigation_agent.target_position-worm_head.global_position).length())
	do_reachable_check = true
	#var next_agent_point = navigation_agent.get_next_path_position()
	#next_agent_point.y = point.y
	
	# if point selected it right on me its possible we cannot get to target so pick again
	##	state = NavigationState.NOT_STARTED
	#else:
	#	print("Navigate to ", next_agent_point)
	#	new_point.emit( next_agent_point )	

	
func _goto_next_point() -> void:
	var next_point = navigation_agent.get_next_path_position()
	next_point.y = worm_head.global_position.y
	
	# if we are close to destination and have been so for a couple of frames
	# force it to move on, as it gets stuck sometimes and NavigationAgent does not contunue
	#var distance_to_target: float = (next_point - get_parent().global_position).length() 
#	if distance_to_target  < 0.1:
	#	print( "%s resetting navigation, target was " % get_parent().player_name, next_point, ", am at ", get_parent().global_position, distance_to_target )
	#	next_point = get_parent().global_position
	#	state = NavigationState.NOT_STARTED
	
	if last_target_point.x != next_point.x or last_target_point.z != next_point.z:
		if debug: print("%s heading to new point " % worm_head.player_name, next_point, " from ", last_target_point)
		new_point.emit( next_point )
		last_target_point = next_point


func _pick_new_target() -> Vector3:
	state = NavigationState.WANDERING
	return Vector3( randf_range(-45,45), worm_head.global_position.y, randf_range(-45,45) )


func _navigation_complete() -> void:
	state = NavigationState.NOT_STARTED 
