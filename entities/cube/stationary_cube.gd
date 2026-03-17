class_name StationaryCube 
extends RigidBody3D
##


## Myself as a preload for spawning instances via StationaryCube.instance(...)
const SELF_SCENE = preload("res://entities/cube/stationary_cube.tscn")

## Number of times its grown out, 1 == 2, 2 == 4, 3 == 8 etc
## [i]Numer value of the block is pow(2,grow_value)[/i]
@export var grow_value: int = 1

@onready var basic_cube: BasicCude = $BasicCube
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var pickup_collision_shape: CollisionShape3D = $PickUpArea3D/PickupCollisionShape


func _ready() -> void:
	collision_shape_3d.shape = basic_cube.box_shape
	basic_cube.set_value_size_and_material(grow_value)
	# make pickup size about 10% bigger the collision shape to ensure bodies pick it
	# update instead of sometimes bumping it if collision shapes where same size
	pickup_collision_shape.shape = BoxShape3D.new()
	pickup_collision_shape.shape.size = collision_shape_3d.shape.size * 1.1
	

func _on_pickup_area_entered(body: Node3D) -> void:
	if multiplayer.is_server():
		if body is WormHeadCube and body.consume_cube(self):
			queue_free()
			
			
static func instance( _transform:Transform3D = Transform3D.IDENTITY, _grow_value: int = 1 ) -> StationaryCube:
	var _instance: StationaryCube = SELF_SCENE.instantiate()
	_instance.name = NetworkManager.get_unique_name( "StationaryCube_" + str(_grow_value) )
	_instance.grow_value = _grow_value
	_instance.transform = _transform
	return _instance
