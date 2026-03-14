class_name StationaryCube 
extends RigidBody3D
##

## Number of times its grown out, 1 == 2, 2 == 4, 3 == 8 etc
## [i]Numer value of the block is pow(2,grow_value)[/i]
@export var grow_value: int = 3

@onready var basic_cube: BasicCude = $BasicCube
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var pickup_collision_shape: CollisionShape3D = $PickUpArea3D/PickupCollisionShape


func _ready() -> void:
	collision_shape_3d.shape = basic_cube.box_shape
	pickup_collision_shape.shape = basic_cube.box_shape
	basic_cube.set_value_size_and_material(grow_value)
	

func _on_pickup_area_entered(body: Node3D) -> void:
	if body is WormHeadCube and body.consume_cube(self):
		# only server can remove the cube or clients produces errors when spawn is replicated
		if is_multiplayer_authority():
			queue_free()
