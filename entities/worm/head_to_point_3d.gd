class_name HeadToPoint3D 
extends Node

@export var motion_source: CharacterBody3D
@export var transform_source: Node3D

@export var destination_point: Vector3
@export var target: CharacterBody3D


func _ready() -> void:
	if target == null:
		target = get_parent()

	# client has authority on replication for this node, as it must replicate new destination
	# point to the server, actual movement code runs only on the server
	if get_parent().get_name().substr(0,2) != "AI":
		print("Set authority on head to point ", int(get_parent().get_name()))
		set_multiplayer_authority( int(get_parent().get_name()) )	
	

func _physics_process(_delta: float) -> void:
	if multiplayer.is_server():
	#	print( "Head to point controlled by ", get_multiplayer_authority() )
		if ( destination_point - target.global_position).length() > 0.075:
			destination_point.y = target.global_position.y
			target.look_at(destination_point)

			var direction = target.transform.basis.z.normalized()
			direction.y = 0
			target.velocity = direction * -target.speed
			target.move_and_slide()
