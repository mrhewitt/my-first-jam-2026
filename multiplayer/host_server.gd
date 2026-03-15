class_name HostServer extends Node

const GAME_WORLD = preload("uid://dwiaescbf4ac6")

## Ref to spawner, we need this so we can setup the path which
## must be monitored for new spawns
@export var multiplayer_spawner: MultiplayerSpawner

## Ref to a node into which we can create a level instance
@export var map_host: Node

var server_level: Node
var worms: Array

func _ready() -> void:
	get_window().title = "Worm Battle [SERVER]"
	
	# start up server and get a notification when its ready 
	NetworkManager.server_started.connect( _on_server_started )
	NetworkManager.create_server()

	# listen for players joining and leaving the server
	NetworkManager.client_connected.connect( _new_player_joined )
	NetworkManager.client_disconnected.connect( _player_left )


## Event handler called when a new player has requested to join the server
func _new_player_joined(peer_id) -> void:
	print("New player connected with peer id ", peer_id )
	# do nothing, client must call with create_worm RPC to spawn a worm as we
	# need details like name to be supplied 
	pass 
	#var worm = WORM_HEAD.instantiate()
	#worm.name = str(peer_id)
	##worm.set_multiplayer_authority(1)
	#worm.global_position = Vector2(200,200)
	#server_level.add_child(worm)
	
	
## Event handler called when player leaves the server
func _player_left( peer_id ) -> void:
	# remove player instance from the world, this will spawn to all clients and remove him
	for child in server_level.get_children():
		if child.name == str(peer_id):
			child.queue_free()


## Event handler called when the server is started
func _on_server_started() -> void:
	server_level = GAME_WORLD.instantiate()
	Bootstrap.map_host.add_child(server_level)
	Bootstrap.multiplayer_spawner.spawn_path = server_level.get_path() #get_tree().current_scene.get_node("%MapHost").get_child(0).get_path()
