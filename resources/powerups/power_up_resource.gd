class_name PowerUpResource
extends Resource
## Implements the effect of a powerup when a PowerUpScene is hit by a worm

## Message shown when a player collects a pickup[br]
## Include a %s so the players name can be included
@export var collect_message: String = ""

## Icon texture the will be placed on the powerup surface
@export var icon: Texture2D

## Additional material that will be used in on top of the icon[br]
@export var material_overlay: Material

## Optional trail effect material, if set will show while powerup active
@export var trail_material: Material

## Apply the powerup to the worm[br]
## Returns false if effect was not applicable and powerup must remain on scene
func apply_effects( worm_head: WormHeadCube ) -> bool:
	return false


## Call this when you want to powerup to be collected[br]
## Calls apply_effects internally and also takes care of displaying a notification
func do_powerup( worm_head: WormHeadCube ) -> bool:
	if apply_effects(worm_head):
		if trail_material:
			worm_head.set_trail_material.rpc( trail_material.resource_path )
		RemoteCall.show_event.rpc( collect_message % worm_head.player_name )
		return true
	else:
		return false
