class_name GameWorld
extends Node3D
##

const CAMERA_BOX = preload("uid://ibhj2qh57jnt")

#@onready var worm_head_cube_2: WormHeadCube = $WormHeadCube2
@export var worm_head_scene: PackedScene

@onready var spawn_point: Marker3D = $SpawnPoint


func link() -> void:
	#worm_head_cube_2.insert_cube_of_value(4)
	#worm_head_cube_2.insert_cube_of_value(3)
	#worm_head_cube_2.insert_cube_of_value(2)
	#worm_head_cube_2.insert_cube_of_value(1)
	pass

## When a player is assigned to the game setup a camera box to track him
func assign_player( player: Node ) -> void:
	var camera_box:CameraBox = CAMERA_BOX.instantiate()
	camera_box.worm_to_follow = player
	add_child(camera_box)
	
	# as this is a player node we need him to respond to input so add
	# and destination provider now that accepts inout
	player.add_destination_provider( player.input_provider_scene.instantiate() )


## Call as an RPC from the client to request server add a new player instance to the game[br]
@rpc("any_peer", "call_remote")
func create_player( player_name: String) -> void:
	print( "%s joined game from peer [%s]" % [player_name, get_multiplayer().get_remote_sender_id() ])	

	var instance:WormHeadCube = worm_head_scene.instantiate()
	#instance.set_multiplayer_authority(1)
		
	# set name of the node to the peer id so we can track players
	instance.name = str( get_multiplayer().get_remote_sender_id() )
	
	instance.player_name = player_name
	instance.grow_value = 2
	instance.global_position = spawn_point.global_position
	
	add_child(instance)
