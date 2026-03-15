extends GameScene

const GAME_WORLD = preload("uid://dwiaescbf4ac6")

## Ref to spawner, we need this so we can setup the path which
## must be monitored for new spawns
#@export var multiplayer_spawner: MultiplayerSpawner

## Ref to a node into which we can create a level instance
#@export var map_host: Node

#@export var player_name: String = "Daddio-Dragonslayer" 

@onready var connecting_label: Label = $CanvasLayer/ConnectingLabel
@onready var connection_lost_label: Label = $CanvasLayer/ConnectionLostLabel
@onready var play_button: Button = $CanvasLayer/PlayButton
@onready var player_name_input: TextEdit = $CanvasLayer/PlayerNameInput

var level_instance: GameWorld


func _ready() -> void:
	player_name_input.text = RandomNameGenerator.pick_one()



func connect_server() -> void:
	connecting_label.visible = true
	play_button.visible = false
	player_name_input.visible = false
	
	NetworkManager.client_connected.connect(_on_connected)
	NetworkManager.server_connection_lost.connect(_on_disconnected)
	NetworkManager.connect_to_server()
	
	
func enter_game() -> void:
	visible = false
	level_instance.visible = true
	
	
func get_player_name() -> String:
	var _name: String = player_name_input.text 
	return player_name_input.placeholder_text if _name == "" else _name 
	
	
## Event called when the player is connect to the server
## [param remote_peer_id] id of remote connection, NOT our peer id
func _on_connected( remote_peer_id: int) -> void:
	print("Client connected to remote peer ", remote_peer_id)
	
	# hide UI notification
	connecting_label.visible = false
	
	# boot up a level on our client side
	level_instance = GAME_WORLD.instantiate()
	# remain hidden until player node is fully replicated to us
	level_instance.visible = false
	Bootstrap.map_host.add_child(level_instance)
	# set spawner so we can sync with server
	Bootstrap.multiplayer_spawner.spawn_path = level_instance.get_path()  #get_tree().current_scene.get_node("%MapHost").get_child(0).get_path()

	# add out player to the game and get notified when objects spawn so we can wait until
	# our player appears, then let game world know he is in and it can start
	Bootstrap.multiplayer_spawner.spawned.connect( _on_player_spawned )
	level_instance.create_player.rpc( get_player_name() )
	

## Check each node being spawned in map until we find the player for our client[br]
## Client enters the game when this happens
func _on_player_spawned(node: Node) -> void:
	print("Spawned a ", node.get_name())
	# wait until a node with our network as its name comes in
	if node.get_name() == str(multiplayer.get_unique_id()):
		print("Entering game as ", node.player_name )
		Bootstrap.multiplayer_spawner.spawned.disconnect( _on_player_spawned )
		level_instance.assign_player( node )
		enter_game()
	

func _on_disconnected() -> void:
	print("Connection lost ")
	connection_lost_label.visible = true
	level_instance.queue_free()
	
	#print( "%s to peer [%s] from peer [%s]" % [msg, get_multiplayer().get_unique_id(), get_multiplayer().get_remote_sender_id() ])	


func _on_play_button_pressed() -> void:
	connect_server()
