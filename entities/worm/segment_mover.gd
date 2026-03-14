extends Node

@export var target: WormSegment


func _ready() -> void:
	if target == null:
		target = get_parent()
		
