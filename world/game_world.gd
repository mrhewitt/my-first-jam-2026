class_name GameWorld
extends GameScene3D
##

#@onready var worm_head_cube_2: WormHeadCube = $WormHeadCube2
@export var worm_head_scene: PackedScene

@onready var ai_spawn_points: Node3D = $AISpawnPoints
@onready var spawn_point: Marker3D = $SpawnPoint
@onready var walls: Node3D = $NavigationRegion3D/Walls
@onready var game_over_canvas_layer: CanvasLayer = $GameOverCanvasLayer
@onready var game_canvas_layer: GameCanvasLayer = $GameCanvasLayer
@onready var block_spawn_timer: Timer = $BlockSpawnTimer

# track which AI spawn point was last used, we move to next one each time we attempt
# to create an AI player
var last_ai_spawn_point: int = -1


func _ready() -> void:
	if multiplayer.is_server():
		# remove UI layers on server, mostly just to make debug easier
		game_over_canvas_layer.queue_free()
		game_canvas_layer.queue_free()
		
		# after all is booted up, put 50 blocks into game to start the map
		get_tree().create_timer(1).timeout.connect( func(): spawn_blocks(Settings.MAX_BLOCKS_IN_MAP) )
		
		# setup and start startionary block spawn timer to fill in blocks that are eaten
		block_spawn_timer.start_in_range( Settings.MIN_BLOCK_RESPAWN_TIME,Settings.MAX_BLOCK_RESPAWN_TIME )
		

func _process(_delta: float) -> void:
	if multiplayer.is_server():
		# if there is at least one connected client ensure
		# that there is a significant amount of AI players
		if get_tree().get_node_count_in_group(Groups.PLAYERS) > 0:
			if get_tree().get_node_count_in_group(Groups.AI) == 0:
				for child in ai_spawn_points.get_children():
					create_ai_player()
					
		# check number of stationary blocks, if there are less than 35 start a timer going
		# to start ranomly adding blocks back into the level


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
		set_random_position(instance)


func set_random_position(instance: Node3D, height: float = 0.5, include_rotation: bool = true) -> void:
	# set position to a random location that is not inside wall	
	instance.global_position = get_random_position(height)
	if include_rotation:
		instance.rotation = Vector3(0, randf() * 2 * PI, 0)	   # turn randonly to look more interesting
	
	var attempts: int = 0
	while attempts < 10 and not GameWorld.is_in_clear_space(instance):
		attempts += 1
		instance.global_position = get_random_position(height)
		if include_rotation:
			instance.rotation = Vector3(0, randf() * 2 * PI, 0)	
		

		
	
func get_random_position( height: float = 0.5) -> Vector3:
	return Vector3( randf_range(-45,45), height, randf_range(-45,45) )


## When a player is assigned to the game setup a camera box to track him[br]
## [color=RED]Run only a client machine!! Only clients get camers[\color]
## [param player] Scene provided to use by the MultiplayerSpawner
func assign_player( player: Node ) -> void:
	add_child( CameraBox.instance(player) )
	
	# as this is a player node we need him to respond to input so add
	# and destination provider now that accepts inout
	player.add_destination_provider( MouseTracker.new() )
	
	# subscribe to killed signal so whe know when its all over for us
	player.been_killed.connect( _on_been_killed ) 


## Call as an RPC from the client to request server add a new player instance to the game[br]
## [param player_name] Human-provided name from the player to have displayed on his character
@rpc("any_peer", "call_remote")
func create_player( player_name: String) -> void:
	print( "%s joined game from peer [%s]" % [player_name, get_multiplayer().get_remote_sender_id() ])	

	var instance:WormHeadCube = worm_head_scene.instantiate()
		
	# set name of the node to the peer id so we can track players
	instance.name = str( get_multiplayer().get_remote_sender_id() )
	
	instance.player_name = player_name
	instance.grow_value = 1
	instance.global_position = spawn_point.global_position
	# make sure its in group of human players, done manually as ai and human use same player node
	instance.add_to_group( Groups.PLAYERS )
	
	add_child(instance)
	instance.show_join_notification()


func create_ai_player() -> void:
	var instance:WormHeadCube = worm_head_scene.instantiate()
		
	# set name of the node to the peer id so we can track players
	instance.name = NetworkManager.get_unique_name("AI")
	instance.add_to_group(Groups.AI)
	
	instance.player_name = RandomNameGenerator.pick_one()
	instance.grow_value = 1
	
	# select the next AI spawn point in the list, we do this as a cheat to 
	# minimize chance of AI agents spawning on top of one another 
	last_ai_spawn_point = (last_ai_spawn_point+1) % ai_spawn_points.get_child_count()
	
	# as this is a player node we need him to respond to input so add
	# and destination provider now that accepts inout
	instance.add_destination_provider( AiProvider.new() )
	
	# when an AI player is killed wait a period of time then bring in someone new
	instance.been_killed.connect( func(): 
		get_tree().create_timer(
				 randi_range(Settings.MIN_AI_RESPAWN_TIME,Settings.MAX_AI_RESPAWN_TIME)		
		).timeout.connect(create_ai_player)
	)
	
	add_child(instance)
	instance.global_position = ai_spawn_points.get_child(last_ai_spawn_point).global_position

	instance.show_join_notification()
	

func spawn_powerup( powerup: PowerUpResource ) -> void:
	var instance:PowerUpScene = PowerUpScene.instance(powerup)
	add_child(instance)
	set_random_position(instance, 0.5, false)
	instance.global_position.y = 0.05


## Runs on server, time to potentially add a new power up
func _on_powerup_spawn_timer_timeout() -> void:
	# check to see how many power ups we have, if there are not enough spawn one
	if get_tree().get_node_count_in_group(Groups.POWERUPS) < Settings.MAX_POWERUPS_ON_MAP:
		# balance powerups, hard-coded quick minutes before final build, will fix later
		var r = randf()
		if r < 0.6:
			spawn_powerup(PowerUpScene.DOUBLE_SPEED_POWER_UP )
		elif r < 0.95:
			spawn_powerup(PowerUpScene.RESET_SIZE_POWERUP )
		else:
			spawn_powerup(PowerUpScene.DOUBLE_POWER_UP )
		 

## Fired on client when player has been killed
func _on_been_killed( _player: WormHeadCube ) -> void:
	game_over_canvas_layer.prepare_game_over()
	game_canvas_layer.killed_screen.visible = true
	get_tree().create_timer(4.0).timeout.connect( _on_show_game_over )
	SoundPlayer.play( load("uid://bo855p38dbob3") )


func _on_show_game_over() -> void:
	game_canvas_layer.visible = false
	game_over_canvas_layer.visible = true
	

## when continue button is pressed tell game state to move on
func _on_continue_button_pressed() -> void:
	goto_return_state.emit()
	
	
## Given a 3D node, checks this node at its current global transform
## will be in open space, i.e. not in a wall etc
static	func is_in_clear_space( node: Node3D ) -> bool:
	var space_state = node.get_world_3d().direct_space_state

	var params = PhysicsShapeQueryParameters3D.new()
	# Set the posi tion of the query (e.g., at this node's position)
	params.transform = node.global_transform
	params.collide_with_areas = true
	params.shape = node.find_child("CollisionShape3D",true).shape
	
	# any collision means this spot is no good, so also stop when it finds one collision
	var i = space_state.intersect_shape(params, 1)
	if i.size() > 0:
		print( node.name ," is in a wall")
		return false
	
	return true


func _on_block_spawn_timer_timeout() -> void:
	# count how many blocks are in the world, then add back between 10-25% of that
	var blocks_left: float = get_tree().get_node_count_in_group(Groups.CUBE_GROUP)
	var can_spawn: float = Settings.MAX_BLOCKS_IN_MAP - blocks_left
	# do nothing if more than 90% in map
	if blocks_left/Settings.MAX_BLOCKS_IN_MAP < 0.9: 
		# pick between 10-25 by selecting probability, then get value of that and make int
		var spawn_count:int = ceil( randf_range(0.2,0.4) * can_spawn )
		spawn_blocks(spawn_count)
