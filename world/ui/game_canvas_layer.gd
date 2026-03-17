class_name GameCanvasLayer
extends CanvasLayer
##

## Holds a static references to the game UI layer so game play can update elements
static var game_canvas: GameCanvasLayer

@onready var killed_screen: ColorRect = $KilledScreen
@onready var event_label: Label = $EventLabel


func _ready() -> void:
	game_canvas = self
	

## Display the given message in the event label area
func show_event( msg: String ) -> void:
	event_label.show_text( msg )
