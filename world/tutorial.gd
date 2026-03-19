extends Node2D


func _ready() -> void:
	if multiplayer.is_server():
		# no tutorial on server
		queue_free()


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
