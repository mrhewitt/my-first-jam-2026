class_name WormHeadCube
extends WormSegment
## Specialized WormSegment that provides the "player" node for this game


const MAX_LOCATION_HISTORY = 480

const EAT_SOUND = preload("res://resources/audio/collect_cube_sfx.tres")
const MERGE_CUBE_SFX = preload("uid://cpljo8x3yexmd")

## Emitted when this player is eaten
signal been_killed( worm: WormHeadCube )

@export var speed: float = Settings.BASE_WORM_SPEED

## Name to display on the leaderboard for this worm
@export var player_name: String = "You"

## Scene to instantiate on clients to create a dstination provider from user input
@export var input_provider_scene: PackedScene

## if cool down is 0.0 then player can boost speed until this is zero
@export var boost_speed_time: float = Settings.BOOST_SPEED_TIME:
	set(bst):
		boost_speed_time = bst
		if boost_speed_progress and multiplayer and not multiplayer.is_server():
			boost_speed_progress.visible = boost_speed_time > 0 and speed_multiplier > 1 
			boost_speed_progress.value = (boost_speed_time/Settings.BOOST_SPEED_TIME) * 100.0
			
			
@onready var head_to_point_3d: Node = $HeadToPoint3D
@onready var player_name_label: Label  = $PlayerNameLabel
@onready var effect_trail_mesh: MeshInstance3D = $EffectTrailMesh
@onready var boost_speed_progress: TextureProgressBar = $BoostSpeedProgress

var destination_provider: DestinationProvider
var location_history: Array

## if non-zero, boost speed is in cooldown so cannot be used
var boost_speed_cooldown: float = 0

		
# must how fast than base speed we can go
var speed_multiplier: float = 1.0


func _ready() -> void:
	super()
	# show name set by player in the label
	player_name_label.text = player_name
#	effect_trail_mesh.set_multiplayer_authority( int(name) )
	# init the position array just in case ...
	var next_position = global_position
	for i in range(MAX_LOCATION_HISTORY):
		add_to_location_history( next_position)
		next_position = transform.basis.z.normalized() * (speed/60)
	# base target position is always at list end, my position
	#target_position_index = MAX_LOCATION_HISTORY - 1
	
	
func add_destination_provider( provider: DestinationProvider ) -> void:
	destination_provider = provider
	destination_provider.new_point.connect( func(p): head_to_point_3d.destination_point = p )
	destination_provider.boost_speed.connect( func(bs): head_to_point_3d.apply_boost_speed = bs )
	add_child(provider)
	
#	destination_provider = $DestinationProvider
#	if destination_provider:
#		destination_provider.new_point.connect( func(p): head_to_point_3d.destination_point = p )

func _process(delta: float) -> void:
	# if not under a high speed boost, reset speed multipleir
	if speed_multiplier < 2: 
		speed_multiplier = 1.0
	if boost_speed_cooldown > 0.0:
		# decrease boost speed cooldown until it is zero
		boost_speed_cooldown = max(boost_speed_cooldown-delta, 0.0)
	elif boost_speed_time > 0.0 and speed_multiplier < 2.0 and head_to_point_3d.apply_boost_speed:
		# give him a speed multiple for this from
		speed_multiplier = Settings.WORM_SPEED_BOOST_RATE
		# decrease time we are allowed to boost
		boost_speed_time -= delta
		# if out of time start cooldown before increating boost speed time available
		if boost_speed_time <= 0.0:
			boost_speed_cooldown = Settings.BOOST_SPEED_COOLDOWN
	else:		
		# no boost cooldown, and no mouse input and no in cooldown, so increase time availabe
		boost_speed_time = min(boost_speed_time+delta,Settings.BOOST_SPEED_TIME)
		
	
func _physics_process(_delta: float) -> void:
	# if pulling someone clamp their attackment point to our tow point
#	if pulling_cube:
#		pulling_cube.next_direction(rotation) #  follow_tow_point(tow_point_marker.global_position) 
	#if pulling_cube:
	#	pulling_cube.follow_tow_point(tow_point_marker.global_position)
	add_to_location_history(global_position)
	
	var next_cube := pulling_cube
	while next_cube:
		next_cube.position = location_history[next_cube.current_position_index].position
		next_cube.rotation = location_history[next_cube.current_position_index].rotation
		next_cube = next_cube.pulling_cube
	

func add_to_location_history(new_position: Vector3) -> void:
	location_history.push_front( {position = new_position, rotation = rotation} ) # transform.basis.z.normalized()})
	if location_history.size() > MAX_LOCATION_HISTORY:
		location_history.pop_back()
	
	
func get_next_position_index( start_index: int, puller: WormSegment, pullee: WormSegment) -> int:
	var path_len: float = 0
	var target_len: float = (puller.get_block_size()/2.0) + (pullee.get_block_size()/2.0) + Settings.TOW_DISTANCE
	while path_len < target_len:
		path_len += ( location_history[start_index].position - location_history[start_index+1].position ).length()	
		start_index += 1
	return start_index
	
	
func consume_cube( cube: StationaryCube ) -> bool:
	if cube.grow_value <= grow_value:
		play_eat_sound.rpc()
		add_cube(cube)
		return true
	else:
		return false


func hit_by_worm( body: WormHeadCube ) -> void:
	# head has been hit, bigger worm absorbs the others head, smallest dies
	if grow_value > body.grow_value:
		 # i am bigger ....
		insert_cube_of_value( body.grow_value )
		RemoteCall.show_event.rpc( "%s got eaten by %s" % [body.player_name, player_name] )
		body.killed()
	elif body.grow_value > grow_value:
		# i am smaller ...
		body.insert_cube_of_value( grow_value )
		RemoteCall.show_event.rpc( "%s got eaten by %s" % [player_name, body.player_name] )	
		killed()
	else:
		# same size - nothing happens
		pass


func killed() -> void:
	# when we die our tail remains for scavangers
	drop_tail()
	# for server control like AI, will have no effect on clients
	been_killed.emit()
	# let clients know they have been killed so they can emit been_killed
	self.report_death.rpc()
	# free head node as this was absorbed into killers tail
	queue_free()
	
	
func show_join_notification() -> void:
	RemoteCall.show_event.rpc("%s joined the game" % player_name)
	

## Called from sevrer when player dies to let the players know, fires been_killed[br]
## Only the who asked for this player will be subsribed to the signal and can do UI work
@rpc("authority","call_remote")
func report_death() -> void:
	been_killed.emit(self)	
	

@rpc("authority", "call_remote")
func set_trail_material( material_path: String ) -> void:
	effect_trail_mesh.mesh.material = load(material_path)
	effect_trail_mesh.visible = true


@rpc("any_peer", "call_local")
func hide_trail() -> void:
	effect_trail_mesh.visible = false
	

@rpc("authority","call_remote")
func play_eat_sound() -> void:
	# only play the sound on the client who did the eating
	if name == str(multiplayer.get_unique_id()):
		EAT_SOUND.play()


@rpc("authority","call_remote")
func play_merge_sound() -> void:
	# only play the sound on the client who did the eating
	if owned_by.name if owned_by else name == str(multiplayer.get_unique_id()):
		MERGE_CUBE_SFX.play()
