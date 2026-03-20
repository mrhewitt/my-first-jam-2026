extends PowerUpResource
## Implements a powerup that doubles the worms speed for a period of time


## Can only apply this power-up if we are not already at speed
func can_apply( worm_head: WormHeadCube ) -> bool:
	return worm_head.speed_multiplier < 2.0
	
	
func apply_effects( worm_head: WormHeadCube ) -> void:
	worm_head.speed_multiplier = 2.0
	worm_head.get_tree().create_timer(5).timeout.connect( _end_effect.bind(worm_head) )
	
	
func _end_effect(worm_head: WormHeadCube) -> void: 
	worm_head.speed_multiplier = 1.0
	worm_head.hide_trail.rpc()
