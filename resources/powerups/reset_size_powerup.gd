extends PowerUpResource
## Implements a bad power up the resets you back to your start size!!

## Apply the powerup to the worm[br]
## Returns false if effect was not applicable and powerup must remain on scene
func apply_effects( worm_head: WormHeadCube ) -> bool:
	worm_head.drop_tail()
	worm_head.grow_value = 1
	return true
