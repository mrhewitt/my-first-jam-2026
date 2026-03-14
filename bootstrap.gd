extends Node

const MULTIPLAYER_HOST = preload("uid://dkfiy1cunmvyk")
const HOST_SERVER = preload("uid://b2dbm01fqbchm")

var instance

func _ready() -> void:
	lconnect()
	#get_tree().create_timer(1).timeout.connect(lconnect)
	
func lconnect() -> void:
#	instance = LEVEL.instantiate()
#	get_parent().add_child.call_deferred( instance  )
	
	if "--server" in OS.get_cmdline_args():
		instance = HOST_SERVER.instantiate()
		add_child( instance  )
	else:
		instance = MULTIPLAYER_HOST.instantiate()
		add_child( instance  )
		
		#await get_tree().create_timer(3).timeout
		#NetworkManager.connected_to_server.connect(_on_connect)
		#NetworkManager.connect_to_server()



#func _on_connect(peer_id) -> void:
#	print("Client connected ", peer_id)
#	_send_test_message.rpc("Hallo there")
	
	
#func _on_server_started() -> void:
#	instance = LEVEL.instantiate()
#	get_parent().add_child.call_deferred( instance  )	


#@rpc("any_peer")
#func _send_test_message(msg: String) -> void:
#	print( "%s to peer [%s] from peer [%s]" % [msg, get_multiplayer().get_unique_id(), get_multiplayer().get_remote_sender_id() ])	

	
