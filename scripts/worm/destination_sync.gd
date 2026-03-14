class_name DestinationSync 
extends Node

var destination: Vector2 

@export var provider: DestinationPointProvider


func _ready() -> void:
	set_multiplayer_authority( int(get_parent().name) )
	provider.new_point.connect( func(p:Vector2): destination = p )
