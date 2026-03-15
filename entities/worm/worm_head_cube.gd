class_name WormHeadCube
extends WormSegment
##

@export var speed: float = 3

## Name to display on the leaderboard for this worm
@export var player_name: String = "You"

## Scene to instantiate on clients to create a dstination provider from user input
@export var input_provider_scene: PackedScene

@onready var head_to_point_3d: Node = $HeadToPoint3D
@onready var player_name_label: Label3D = $PlayerNameLabel

var destination_provider: DestinationProvider


func _ready() -> void:
	super()

	# show name set by player in the label
	player_name_label.text = player_name
	
	
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
	# only server 
	if cube.grow_value <= grow_value:
		add_cube(cube)
		return true
	else:
		return false


func hit_by_worm( body: WormHeadCube ) -> void:
	# head has been hit, bigger worm absorbs the others head, smallest dies
	if grow_value > body.grow_value:
		 # i am bigger ....
		insert_cube_of_value( body.grow_value )
		body.killed()
	elif body.grow_value > grow_value:
		# i am smaller ...
		body.insert_cube_of_value( grow_value )	
		killed()
	else:
		# same size - nothing happens
		pass


func killed() -> void:
	# when we die our tail remains for scavangers
	drop_tail()
	# free head node as this was absorbed into killers tail
	queue_free()
