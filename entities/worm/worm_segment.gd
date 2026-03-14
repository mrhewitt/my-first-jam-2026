class_name WormSegment
extends CharacterBody3D

const WORM_SEGMENT_SCENE = preload("uid://bhmi3a6gxf46s")

## Ref to the cube that we are pulling directly behind us
@export var pulling_cube: WormSegment

## Number of times its grown out, 1 == 2, 2 == 4, 3 == 8 etc[br]
## [i]Numer value of the block is pow(2,grow_value)[/i]
@export var grow_value: int = 1:
	set(value):
		grow_value = value
		if basic_cube:
			basic_cube.set_value_size_and_material(grow_value)


@onready var basic_cube: BasicCude = $BasicCube
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


func _init( value: int = 1 ) -> void:
	grow_value = value
	
	
func _ready() -> void:
	collision_shape_3d.shape = basic_cube.box_shape
	basic_cube.set_value_size_and_material(grow_value)
	
	
## Add a new cube to our tail, if its right value we put it behind us[br]
## if not keeps looking back recusively down the tail
func add_cube( cube: StationaryCube ) -> void:
	if pulling_cube == null or cube.grow_value > pulling_cube.grow_value:
		var segment := WORM_SEGMENT_SCENE.instantiate( )
#		segment.global_basis = global_basis
		segment.global_position = global_position + Vector3(0,0,1)	
		segment.grow_value = cube.grow_value
		get_parent().add_child( segment )
		
		# insert new segment into pulling chain 
		segment.pulling_cube = pulling_cube
		pulling_cube = segment
	elif pulling_cube:
		pulling_cube.add_cube(cube)
