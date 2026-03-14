class_name HurtBox
extends Area3D
##

## Emitted when this hurtbox has been hit by a worm head
signal hit_by( body: WormHeadCube )

func _on_body_entered(body: Node3D) -> void:
	if body is WormHeadCube:
		hit_by.emit(body)
