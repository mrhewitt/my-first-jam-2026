class_name PowerUpScene
extends Node3D
##

const SELF_SCENE = preload("uid://cs31egmj5atle")

const DOUBLE_POWER_UP = preload("uid://dsjjw04ia500d")
const DOUBLE_SPEED_POWER_UP = preload("uid://b3x50hbalwcf0")
const RESET_SIZE_POWERUP = preload("uid://bqarckuwoiwj6")

const POWERUPS = [
	DOUBLE_POWER_UP,
	DOUBLE_SPEED_POWER_UP,
	RESET_SIZE_POWERUP
]

## Index in [param POWERUPS] of power up to assign to this instance[br]
## The index was unsed intead of actual resource as the resource was not[br]
## syncronizing from server on spawn, but the integer was
@export var power_up_index: int
 
@onready var collision_shape_3d: CollisionShape3D = $Area3D/CollisionShape3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var area_3d: Area3D = $Area3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var active: bool = true
var power_up_type: PowerUpResource


func _ready() -> void:
	power_up_type = POWERUPS[power_up_index]
	
	# setup collision shape so it has same size as the plane mesh
#	collision_shape_3d.shape = BoxShape3D.new()
#	var x: float = mesh_instance_3d.mesh.size.x
	#var z: float = mesh_instance_3d.mesh.size.y
#	collision_shape_3d.shape.size = Vector3(x,2.0,z)
	
	mesh_instance_3d.mesh = PlaneMesh.new()
	mesh_instance_3d.mesh.size = Vector2(2.0,2.0)
	
	# create a material to textre the plane mesh
	mesh_instance_3d.mesh.material = MaterialHelper.get_texture_material( power_up_type.icon )
	# if there is a material as well use this an the material overlay
	if power_up_type.material_overlay:
		mesh_instance_3d.material_overlay = power_up_type.material_overlay 
	
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if active and body is WormHeadCube and multiplayer.is_server() and power_up_type.can_apply(body):
		power_up_type.do_powerup(body)			
		area_3d.queue_free()
		active = false
		animation_player.play("remove")
		await animation_player.animation_finished
		queue_free()
		

static func instance( power_up: PowerUpResource ) -> PowerUpScene:
	var self_instance: PowerUpScene = SELF_SCENE.instantiate()
	self_instance.name = NetworkManager.get_unique_name("PowerUp") 
	
	# use the index for replication
	for i in range(POWERUPS.size()):
		if POWERUPS[i] == power_up:
			self_instance.power_up_index = i
	return self_instance
	
	
