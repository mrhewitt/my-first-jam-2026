extends Node2D


func _on_server_button_pressed() -> void:
	NetworkManager.create_server()


func _on_join_button_pressed() -> void:
	NetworkManager.connect_to_server()
	

func _on_send_button_pressed() -> void:
	_send_test_message.rpc("Hallo there")
	

@rpc("any_peer")
func _send_test_message(msg: String) -> void:
	print( "%s to peer [%s] from peer [%s]" % [msg, get_multiplayer().get_unique_id(), get_multiplayer().get_remote_sender_id() ])	
