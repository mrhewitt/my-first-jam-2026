extends GameScene

@onready var label: Label = $Label
@onready var button: Button = $Button
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var connecting_label: Label = $Label2

func _ready() -> void:
	label.visible = NetworkManager.is_server
	if not NetworkManager.is_server:
		_send_test_message.rpc("message to server from new client")
	#3button.pressed.connect(_connect_to_server)
	#NetworkManager.server_started.connect(_server_up)
	#if  NetworkManager.is_server:
		
		#get_multiplayer().peer_connected.connect( _join_success )
	#button.visible = true


@rpc("any_peer")
func _send_test_message(msg: String) -> void:
	print( "%s to peer [%s] from peer [%s]" % [msg, get_multiplayer().get_unique_id(), get_multiplayer().get_remote_sender_id() ])	
