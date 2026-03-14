extends Node3D

@onready var worm_head_cube: WormHeadCube = $WormHeadCube


func _physics_process(delta: float) -> void:
	# follow the worm head by position so camera follows, 
	# but not roration as we have a fixed to=the-back view
	#global_position = worm_head_cube.global_position
	pass
