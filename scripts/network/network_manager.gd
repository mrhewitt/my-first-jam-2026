extends Node
## Autoload for managing multiplayer network connections
##
##


const SERVER_PORT = "6069"
const DEV_SERVER_ADDR = "ws://127.0.0.1:" + SERVER_PORT
const PROD_SERVER_ADDR = "wss://server.dragonslayergames.co.za:" + SERVER_PORT

## Emitted when a client loses connection to a server
signal server_connection_lost

## Emitted when a client has successfuly connected to the server
## [param peer_id] is the clients peer id for authentiation
signal client_connected(peer_id: int)

## Emitted when a client has been dropped/left
signal client_disconnected(peer_id: int)


## Emitted when a server has successfully started up
signal server_started


func _ready() -> void: 
	get_multiplayer().peer_connected.connect( _on_peer_connected )
	get_multiplayer().peer_disconnected.connect( func(id): client_disconnected.emit(id) )


func create_server() -> void:
	var network_peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	network_peer.create_server(int(SERVER_PORT))
	get_multiplayer().multiplayer_peer = network_peer
	print("Server created")
	server_started.emit()
	
	
func connect_to_server( ) -> void:
	_setup_client_connection_signals()
	
	var network_peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	network_peer.create_client( PROD_SERVER_ADDR if OS.has_feature("production") else DEV_SERVER_ADDR)
	get_multiplayer().multiplayer_peer = network_peer
	
	print("Client connection pending")
	#connected_to_server.emit( get_tree().get_multiplayer().get_unique_id() )


## Returns a unique name that can be used for a node to ensure successful replication[br]
## [i]Node will not replicate if they do not have a name assigned, you MUST set instance.name = ...[br]
## before adding the node to the scene tree to ensure successful replication[\i]
func get_unique_name(prefix: String) -> String:
	return prefix + "_" + UUID.v4()
	
	
func _setup_client_connection_signals() -> void:
	if not get_multiplayer().server_disconnected.is_connected(_server_disconnected):
		get_multiplayer().server_disconnected.connect( _server_disconnected )
	

func _disconnect_client_connection_signals():
	for connection in get_multiplayer().server_disconnected.get_connections():
		get_multiplayer().server_disconnected.disconnect(connection.callable)
		

## When a peer connection is made emit client connected event[br]
## [color=RED]peer_connected is emitted when ANYONE connects to game[/color][br]
## This method filters it so client_connected is emitted only when peer is the server[br]
func _on_peer_connected(peer_id: int) -> void:
	if peer_id == 1: 
		client_connected.emit(peer_id)
		
		
func _server_disconnected() -> void:
	print("Lost server...")
	_terminate_connection()
	server_connection_lost.emit()


func _terminate_connection():
	print("Terminate connection")
	get_multiplayer().multiplayer_peer = null
	_disconnect_client_connection_signals()
