class_name HurtBox
extends Area3D
##

## Emitted when this hurtbox has been hit by a worm head
signal hit_by( body: WormHeadCube )

## Check if a WormHead entered the hitbox and emit hit_by if so[br]
## [i]Only runs on server as server has authorirty on node position/creation/removal[/i]
func _on_body_entered(body: Node3D) -> void:
	if body is WormHeadCube and multiplayer.is_server():
		hit_by.emit(body)
