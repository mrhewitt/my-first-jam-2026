class_name WormHeadCube
extends WormSegment
## Specialized WormSegment that provides the "player" node for this game


## Emitted when this player is eaten
signal been_killed( worm: WormHeadCube )

@export var speed: float = 3

## Name to display on the leaderboard for this worm
@export var player_name: String = "You"

## Scene to instantiate on clients to create a dstination provider from user input
@export var input_provider_scene: PackedScene

@onready var head_to_point_3d: Node = $HeadToPoint3D
@onready var player_name_label: Label3D = $PlayerNameLabel
@onready var effect_trail_mesh: MeshInstance3D = $EffectTrailMesh

var destination_provider: DestinationProvider


func _ready() -> void:
	super()

	# show name set by player in the label
	player_name_label.text = player_name
#	effect_trail_mesh.set_multiplayer_authority( int(name) )

	
func add_destination_provider( provider: DestinationProvider ) -> void:
	destination_provider = provider
	destination_provider.new_point.connect( func(p): head_to_point_3d.destination_point = p )
	add_child(provider)
	
#	destination_provider = $DestinationProvider
#	if destination_provider:
#		destination_provider.new_point.connect( func(p): head_to_point_3d.destination_point = p )


func _physics_process(_delta: float) -> void:
	# if pulling someone clamp their attackment point to our tow point
#	if pulling_cube:
#		pulling_cube.next_direction(rotation) #  follow_tow_point(tow_point_marker.global_position) 
	if pulling_cube:
		pulling_cube.follow_tow_point(tow_point_marker.global_position)


func consume_cube( cube: StationaryCube ) -> bool:
	if cube.grow_value <= grow_value:
		if !multiplayer.is_server():
			SoundPlayer.play( load("res://resources/audio/collect_cube_sfx.tres") )
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
