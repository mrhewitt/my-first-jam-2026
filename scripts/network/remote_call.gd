extends Node
## Provides some common RPC methods to pass events through to clients primarily


## Display the given message in the event label area
@rpc("any_peer", "call_remote")
func show_event( msg: String ) -> void:
	if is_instance_valid(GameCanvasLayer.game_canvas):
		print("Peer ", multiplayer.get_unique_id(), " show event ", msg )
		GameCanvasLayer.game_canvas.show_event( msg )
	else:
		print("Peer ", multiplayer.get_unique_id(), " no canvas for ", msg )
