extends TextureProgressBar

## Worm head to appear above, null to default to parent
@export var target: WormHeadCube


func _ready():
	if target == null:
		target = get_parent()
		
	
func _process(_delta: float) -> void:
	# Convert the 3d global position to screen-space coordinates
	if CameraBox.world_camera:
		var screen_pos = CameraBox.world_camera.unproject_position(target.global_position) 
		global_position = screen_pos
		#  you can adjust the position for visual clarity
		global_position += Vector2(-get_rect().size.x / 2, -50 - (16 * target.basic_cube.get_scale_factor(target.grow_value)) - (get_rect().size.x / 2))
	
