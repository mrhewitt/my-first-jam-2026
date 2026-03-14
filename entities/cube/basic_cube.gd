class_name BasicCude 
extends Node3D
##

const MATERIAL_PATH = "res://resources/materials/cubes/cube_%d_material.tres"

## Start size of the smallest cube, length of one side
@export var min_size: float = 0.5

## How much cube grows on each size
@export var growth_factor: float = 2.2

## Box shape matching cube size, assing to your collision shape in compositions
@export var box_shape: BoxShape3D

## Material to assign to the box
@export var cube_material: BaseMaterial3D:
	set( material ):
		if material and mesh_instance_3d and mesh_instance_3d.mesh:
			mesh_instance_3d.mesh.material = material

## Mesh to use for the cubes appearance
@export var shape_mesh: PrimitiveMesh 

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	box_shape = BoxShape3D.new()
	mesh_instance_3d.mesh = shape_mesh.duplicate()


## Given a growth value sets up appropriate cube scale and materials
## [param grow_value] How many times has the block grow out, 1 for base, 2 for next size, 3 next  etc
func set_value_size_and_material( grow_value: int ) -> void:
	# scale of the object is the base growth factor to the exponent of the
	# number of times grow out less one, so first size becomes 1, and subsequantly
	# ^2  ^4  etc
	var scale: float = pow(growth_factor, grow_value - 1 )
	var size: float = scale * min_size
	box_shape.size = Vector3(size,size,size) 
	mesh_instance_3d.scale = Vector3( scale, scale, scale )
#	mesh_instance_3d.position.y = (mesh_instance_3d.scale.y * 0.5) 
#	print( mesh_instance_3d.position.y )
	cube_material = load( MATERIAL_PATH % pow(2,grow_value) )
