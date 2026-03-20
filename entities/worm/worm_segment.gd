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
## [i]Numer value of the block is pow(2,grow_value)[/i][br]
## Clamped in this version to between 2 and 2048
@export var grow_value: int = 1:
	set(value):
		grow_value = clamp(value,1,11)
		setup_size()
			#set_hurtbox_collision_size()

@onready var basic_cube: BasicCude = $BasicCube
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var tow_point_marker: Marker3D = $TowPointMarker
@onready var attachment_point_marker: Marker3D = $AttachmentPointMarker
@onready var hurt_box_shape_3d: CollisionShape3D = $HurtBox/HurtBoxShape3D

var upcoming_direction: Vector3

var tow_distance: float = Settings.MIN_BLOCK_SIZE / 2

var merging: bool = false

var current_position_index: int = 0
var target_position_index: int = 0


func _init( value: int = 1 ) -> void:
	grow_value = value
	
	
func _ready() -> void:
	setup_size()
	# if we are a segment (owned) make sure we cannot collide with our own head
	if owned_by != null:
		add_collision_exception_with(owned_by)
		owned_by.add_collision_exception_with(self)
		
	#collision_shape_3d.shape = basic_cube.box_shape
	#basic_cube.set_value_size_and_material(grow_value)
	#set_hurtbox_collision_size()
	# after a slight delay check to see if we can merge with block in front of us
	start_merge_check_clock()


func _process(_delta: float) -> void:
	if target_position_index > current_position_index:
		current_position_index += 1
	elif target_position_index < current_position_index:
		current_position_index -= 1
	if merging and target_position_index == current_position_index:
		merge_with_puller()


#func _physics_process(delta: float) -> void:
	# only on server, as server has authority, replicates trasnforms
	# and is responsible for free controlled nodes
	#if merging and multiplayer.is_server():
	#	look_at( pulled_by.global_position )
	#	global_position = global_position.move_toward( pulled_by.global_position, delta * 15 ) 
	#	if (pulled_by.global_position - global_position).length() < 0.05:
	#		pulled_by.grow_value += 1
	#		pulled_by.pulling_cube = pulling_cube
	#		if pulling_cube:
	#			pulling_cube.pulled_by = pulled_by
	#		pulled_by.start_merge_check_clock()
	#		merging = false
	#		queue_free()
	
func setup_size() -> void:
	if basic_cube:
		var new_scale = basic_cube.get_scale_factor(grow_value)
		scale = Vector3(new_scale,new_scale,new_scale)
		basic_cube.set_value_size_and_material(grow_value)
		global_position.y = get_block_size()/2 + Settings.HEIGHT_OFF_GROUND


## Get size (length of one side) of the block in its current grow state 
func get_block_size() -> float:
	return basic_cube.get_scale_factor(grow_value) * Settings.MIN_BLOCK_SIZE


func merge_with_puller() -> void:
	pulled_by.grow_value += 1
	if is_instance_valid(pulling_cube):
		pulled_by.pulling_cube = pulling_cube
		if pulling_cube:
			# shift position of cubes in our tail forward
			pulling_cube.reposition()
			pulling_cube.pulled_by = pulled_by
	else:
		pulled_by.pulling_cube = null
	pulled_by.start_merge_check_clock()
	merging = false
	queue_free()
	
			
func set_hurtbox_collision_size() -> void:
	# make hurtbox size about 10% bigger the collision shape to ensure bodies pick it
	# update instead of sometimes bumping it if collision shapes where same size
	hurt_box_shape_3d.shape.size = collision_shape_3d.shape.size * 1.1


func start_merge_check_clock() -> void:
	# only the sever will merge blocks
	if multiplayer.is_server():
		get_tree().create_timer( Settings.BLOCK_MERGE_DELAY ).timeout.connect( check_start_merge_block )


func next_direction( dir: Vector3 ) -> void:
	rotation = upcoming_direction
	if pulling_cube:
		pulling_cube.next_direction( rotation )
	upcoming_direction = dir
	

## Causes this segment to track its town point to create illusion it is being pulled
## [i]Only runs on server as server has authority on transforms, final transform is replicated[/i] 
func follow_tow_point( tow_point: Vector3 ) -> void:
	if not merging and multiplayer.is_server():
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
		segment.pulling_cube = pulling_cube if is_instance_valid(pulling_cube) else null
		segment.pulled_by = self
		pulling_cube = segment
		segment.reposition()
	elif pulling_cube:
		pulling_cube.insert_cube_of_value( value )


## Calculate a new position index for myself and tail[br]
## Useful when adding new blocks or after a merge 
func reposition() -> void:
	# get a location position index for new segment
	query_position_index( )
	# ask all those in our tail to shift backwards
	var cube := pulling_cube
	while cube != null:
		cube.query_position_index( )
		cube = cube.pulling_cube
			
			
func query_position_index( ) -> void :
	target_position_index = owned_by.get_next_position_index( pulled_by.target_position_index, pulled_by, self )
	# if no current index set its a new spawn, so set direct to final target
	if current_position_index == 0:
		current_position_index = target_position_index


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
	if pulled_by and pulled_by.grow_value == grow_value: #and ( pulling_cube == null or pulling_cube.grow_value < grow_value):
		owned_by.play_merge_sound.rpc()
		merging = true
		# go into the target blopck
		target_position_index = pulled_by.target_position_index
		# disable collision shape when we merge as we have been processed and cannot collide with our own head
		collision_shape_3d.set_deferred("disabled", true)
		

func create_worm_segment( value: int ) -> WormSegment:
	var segment := WormSegment.instance( self if self.owned_by == null else self.owned_by, value )
	get_parent().add_child( segment )
	return segment


func get_tow_distance() -> float:
	return tow_distance + ( Settings.MIN_BLOCK_SIZE * basic_cube.mesh_instance_3d.scale.x )


func _on_timer_timeout() -> void:
	if pulling_cube:
		pulling_cube.next_direction(rotation)


func _on_hurt_box_hit_by(body: WormHeadCube) -> void:
	hit_by_worm( body )
		
		
static func instance( _owned_by: WormHeadCube, _grow_value: int = 1 ) -> WormSegment:
	var scene_instance: WormSegment = SELF_SCENE.instantiate()
	# segments are named after the network id of owner 
	scene_instance.name = NetworkManager.get_unique_name("Segment_" + _owned_by.name) 
	scene_instance.grow_value = _grow_value
	scene_instance.owned_by = _owned_by
	return scene_instance
