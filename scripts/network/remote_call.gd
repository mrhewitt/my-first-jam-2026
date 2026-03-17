extends Node
## Provides some common RPC methods to pass events through to clients primarily


## Display the given message in the event label area
@rpc("authority", "call_remote")
func show_event( msg: String ) -> void:
	if is_instance_valid(GameCanvasLayer.game_canvas):
		GameCanvasLayer.game_canvas.show_event( msg )
