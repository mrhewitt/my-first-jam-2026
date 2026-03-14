class_name GameWorld
extends Node3D
##

@onready var worm_head_cube_2: WormHeadCube = $WormHeadCube2

func _ready() -> void:
	#get_tree().create_timer(5).timeout.connect(link)
	link()
	
func link() -> void:
	worm_head_cube_2.insert_cube_of_value(4)
	worm_head_cube_2.insert_cube_of_value(3)
	worm_head_cube_2.insert_cube_of_value(2)
	worm_head_cube_2.insert_cube_of_value(1)
	pass
