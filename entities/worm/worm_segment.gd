class_name WormSegment
extends CharacterBody3D
##


## Myself as a preload for spawning instances via WormSegment.instance(...)
const SELF_SCENE = preload("uid://bhmi3a6gxf46s")

## Ref to the cube that we are pulling directly behind us
@export var pulling_cube: WormSegment

## Ref to the cube the is pulling us, making it a linked list
@export var pulled_by: WormSegment

## Ref to the head the owns us
@export var owned_by: WormHeadCube

## Number of times its grown out, 1 == 2, 2 == 4, 3 == 8 etc[br]
## [i]Numer value of the block is pow(2,grow_value)[/i]
@export var grow_value: int = 1:
	set(value):
		grow_value = value
		if basic_cube:
			basic_cube.set_value_size_and_material(grow_value)
			set_hurtbox_collision_size()

@onready var basic_cube: BasicCude = $BasicCube
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var tow_point_marker: Marker3D = $TowPointMarker
@onready var attachment_point_marker: Marker3D = $AttachmentPointMarker
@onready var hurt_box_shape_3d: CollisionShape3D = $HurtBox/HurtBoxShape3D

var upcoming_direction: Vector3

var tow_distance: float = Settings.MIN_BLOCK_SIZE*2

var merging: bool = false

func _init( value: int = 1 ) -> void:
	grow_value = value
	
	
func _ready() -> void:
	collision_shape_3d.shape = basic_cube.box_shape
	basic_cube.set_value_size_and_material(grow_value)
	set_hurtbox_collision_size()
	# after a slight delay check to see if we can merge with block in front of us
	start_merge_check_clock()


func _physics_process(delta: float) -> void:
	if merging:
		look_at( pulled_by.global_position )
		global_position = global_position.move_toward( pulled_by.global_position, delta * 5 ) 
		if (pulled_by.global_position - global_position).length() < 0.05:
			pulled_by.grow_value += 1
			pulled_by.pulling_cube = pulling_cube
			if pulling_cube:
				pulling_cube.pulled_by = pulled_by
			pulled_by.start_merge_check_clock()
			queue_free()
			
			
func set_hurtbox_collision_size() -> void:
	# make hurtbox size about 10% bigger the collision shape to ensure bodies pick it
	# update instead of sometimes bumping it if collision shapes where same size
	hurt_box_shape_3d.shape.size = collision_shape_3d.shape.size * 1.1


func start_merge_check_clock() -> void:
	get_tree().create_timer( Settings.BLOCK_MERGE_DELAY ).timeout.connect( check_start_merge_block )


func next_direction( dir: Vector3 ) -> void:
	rotation = upcoming_direction
	if pulling_cube:
		pulling_cube.next_direction( rotation )
	upcoming_direction = dir
	

func follow_tow_point( tow_point: Vector3 ) -> void:
	if not merging:
		# rotate so we are facing the towpoint square on
		look_at(tow_point)
		# and use transform rotation vector to move back to leave a towing distance
		global_position = tow_point + (transform.basis.z.normalized() * get_tow_distance()) 

		#look_at(tow_point)
		
		# if we are pulling someone pass the tow action down the line
		if pulling_cube:
			pulling_cube.follow_tow_point( tow_point_marker.global_position )


## Add a worm segment of same type as given stationary block in correct place in our tail
func add_cube( cube: StationaryCube ) -> void:
	insert_cube_of_value( cube.grow_value )
	
	
## Add a new cube of given into our tail[br]
## if its right value we put it behind us, if not keeps looking back recusively down the tail
func insert_cube_of_value( value: int ) -> void:
	if pulling_cube == null or value > pulling_cube.grow_value:
		var segment := create_worm_segment( value )
		
		# insert new segment into pulling chain 
		if pulling_cube:
			pulling_cube.pulled_by = segment
		segment.pulling_cube = pulling_cube
		segment.pulled_by = self
		pulling_cube = segment
	elif pulling_cube:
		pulling_cube.insert_cube_of_value( value )


## Drops all segments in my tail into stationary blocks
func drop_tail() -> void:
	var segment = pulling_cube
	while segment != null:
		segment.convert_to_stationary()	
		segment = segment.pulling_cube
	pulling_cube = null		# we are now end of the queue 


func convert_to_stationary() -> void:
	get_parent().add_child( StationaryCube.instance( transform, grow_value ) )
	queue_free()


func hit_by_worm( body  ) -> void:
	# first make sure the head that hit us is not our own
	if owned_by != body:
		# segment has been hit by a larger head, so it gets absorbed
		# by worm hitting us, and tail is left behind
		if body.grow_value > grow_value: 
			body.insert_cube_of_value( grow_value )
			drop_tail()
			queue_free()
			

func check_start_merge_block() -> void:
	# we can merge into block in front of us provuided it is same value as us, and we are the last
	# block of this value in the chain
	if pulled_by and pulled_by.grow_value == grow_value and ( pulling_cube == null or pulling_cube.grow_value < grow_value):
		merging = true


func create_worm_segment( value: int ) -> WormSegment:
	var segment := WormSegment.instance( self if self.owned_by == null else self.owned_by, value )
	get_parent().add_child( segment )
	var td = get_tow_distance()
	segment.global_position = global_position + Vector3( sin(rotation.y+PI) * td, 0, cos(rotation.y+PI) * -td )
	return segment


func get_tow_distance() -> float:
	return tow_distance + ( Settings.MIN_BLOCK_SIZE * basic_cube.mesh_instance_3d.scale.x )


func _on_timer_timeout() -> void:
	if pulling_cube:
		pulling_cube.next_direction(rotation)


func _on_hurt_box_hit_by(body: WormHeadCube) -> void:
	hit_by_worm( body )
	
	
static func instance( owned_by: WormHeadCube, grow_value: int = 1 ) -> WormSegment:
	var scene_instance: WormSegment = SELF_SCENE.instantiate()
	# segments are named after the network id of owner 
	scene_instance.name = NetworkManager.get_unique_name("Segment_" + owned_by.name) 
	scene_instance.grow_value = grow_value
	scene_instance.owned_by = owned_by
	return scene_instance
