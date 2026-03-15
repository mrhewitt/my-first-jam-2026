class_name GameWorld
extends Node3D
##

#@onready var worm_head_cube_2: WormHeadCube = $WormHeadCube2
@export var worm_head_scene: PackedScene

@onready var spawn_point: Marker3D = $SpawnPoint


func _ready() -> void:
	if multiplayer.is_server():
		get_tree().create_timer(1).timeout.connect( func(): spawn_blocks(50) )
	

func link() -> void:
	#worm_head_cube_2.insert_cube_of_value(4)
	#worm_head_cube_2.insert_cube_of_value(3)
	#worm_head_cube_2.insert_cube_of_value(2)
	#worm_head_cube_2.insert_cube_of_value(1)
	pass
	
	
## Add a set of stationary blocks into the level in random places
## [param total] How many blocks to spawn
func spawn_blocks( total: int ) -> void:
	for i in range(total):
		var probability := randf()
		var instance := StationaryCube.instance()
		
		# accum probabilities in the spawn list, this way as soon as we find one
		# that is greater than nmber chosen above we pick it, as the random selection is
		# within the range of probbsility of the block at that point
		var type_probability: float = 0
		for growth_size in range( Settings.CUBE_SPAWN_PROB.size() ):
			type_probability += Settings.CUBE_SPAWN_PROB[growth_size]
			if probability <= type_probability:
				instance.grow_value = growth_size + 1		# plus 1 as loop is zero based
				break
		add_child(instance)

		# set position to a random location that is not inside wall	
		instance.global_position = get_random_position()
		instance.rotation = Vector3(0, randf() * 2 * PI, 0)	   # turn randonly to look more interesting
		while not is_in_clear_space(instance):
			instance.global_position = get_random_position()
			instance.rotation = Vector3(0, randf() * 2 * PI, 0)	
		
	
func is_in_clear_space( node: Node3D ) -> bool:
	var space_state = get_world_3d().direct_space_state
	
	for wall in $Walls.get_children():
	#	var static_body = wall.find_child("StaticBody3D")
	#	var collision_shape: CollisionShape3D = static_body.get_child(0)

		var params = PhysicsShapeQueryParameters3D.new()
		params.shape = wall.bake_collision_shape() 
	
		# Set the position of the query (e.g., at this node's position)
		params.transform = node.global_transform
		params.collide_with_areas = true
		params.exclude = [RID(node)]  # Exclude self
		
		# any collision means this spot is no good, so also stop when it finds one collision
		if space_state.intersect_shape(params, 1).size() > 0:
			print("Block is in a wall")
			return false
	
	return true
		
	
func get_random_position() -> Vector3:
	return Vector3( randf_range(-45,45), 0.5, randf_range(-45,45) )


## When a player is assigned to the game setup a camera box to track him
## [param player] Scene provided to use by the MultiplayerSpawner
func assign_player( player: Node ) -> void:
	add_child( CameraBox.instance(player) )
	
	# as this is a player node we need him to respond to input so add
	# and destination provider now that accepts inout
	player.add_destination_provider( player.input_provider_scene.instantiate() )


## Call as an RPC from the client to request server add a new player instance to the game[br]
## [param player_name] Human-provided name from the player to have displayed on his character
@rpc("any_peer", "call_remote")
func create_player( player_name: String) -> void:
	print( "%s joined game from peer [%s]" % [player_name, get_multiplayer().get_remote_sender_id() ])	

	var instance:WormHeadCube = worm_head_scene.instantiate()
		
	# set name of the node to the peer id so we can track players
	instance.name = str( get_multiplayer().get_remote_sender_id() )
	
	instance.player_name = player_name
	instance.grow_value = 2
	instance.global_position = spawn_point.global_position
	
	add_child(instance)
