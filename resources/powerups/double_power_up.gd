extends PowerUpResource
## Implements a power up that cuases worm to double in size


## Can always double size
func can_apply( _worm_head: WormHeadCube ) -> bool:
	return true
	
	
## Apply the powerup to the worm[br]
## Returns false if effect was not applicable and powerup must remain on scene
func apply_effects( worm_head: WormHeadCube ) -> void:
	var segment: WormSegment = worm_head
	var end_segment: WormSegment = worm_head
	while segment != null:
		segment.grow_value += 1
		segment = segment.pulling_cube
		# keep a ref to very end so we can start merge from the back
		if segment != null: end_segment = segment 
	end_segment.start_merge_check_clock()
