extends PowerUpResource
## Implements a powerup that doubles the worms speed for a period of time



func apply_effects( worm_head: WormHeadCube ) -> bool:
	worm_head.speed *= 2
	worm_head.get_tree().create_timer(5).timeout.connect( func(): worm_head.speed /= 2 )
	return true
	
