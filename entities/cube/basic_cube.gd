class_name BasicCude 
extends Node3D
##

const CUBE_MATERIAL = preload("res://resources/materials/cubes/cube_material.tres")

@export var color_list : Array[Color]

## Start size of the smallest cube, length of one side
@export var min_size: float = 0.5

## How much cube grows on each size
@export var growth_factor: float = Settings.GROW_RATIO

## Box shape matching cube size, assing to your collision shape in compositions
@export var box_shape: BoxShape3D

## Material to assign to the box
@export var cube_material: BaseMaterial3D:
	set( material ):
		if material and mesh_instance_3d and mesh_instance_3d.mesh:
			#mesh_instance_3d.mesh.material = material
			mesh_instance_3d.material_override = material

## Mesh to use for the cubes appearance##
#@export var shape_mesh: PrimitiveMesh 

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	box_shape = BoxShape3D.new()
	#mesh_instance_3d.mesh = shape_mesh.duplicate()


## Given a growth value sets up appropriate cube scale and materials
## [param grow_value] How many times has the block grow out, 1 for base, 2 for next size, 3 next  etc
func set_value_size_and_material( grow_value: int ) -> void:
	##var _scale: float = get_scale_factor(grow_value)
	##var size: float = _scale * min_size
	##box_shape.size = Vector3(size,size,size) 
	##mesh_instance_3d.scale = Vector3( _scale, _scale, _scale )
	var material: StandardMaterial3D = CUBE_MATERIAL.duplicate()
	material.albedo_color = color_list[grow_value-1]
	mesh_instance_3d.material_override = material
	
	
## scale of the object is the base growth factor to the exponent of the[br]
## number of times grow out less one, so first size becomes 1, and subsequantly[br]
## ^2  ^4  etc
func get_scale_factor( grow_value: float ) -> float:
	return pow( growth_factor, grow_value - 1 )
