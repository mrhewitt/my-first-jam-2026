class_name HostServer extends Node

const LEVEL = preload("uid://d2ufjf8lvutq6")
const WORM_HEAD = preload("uid://baru26u8lsvws")

@onready var multiplayer_spawner: MultiplayerSpawner

var server_level : CanvasItem
var worms: Array

func _ready() -> void:
	multiplayer_spawner = get_tree().current_scene.get_node("%MultiplayerSpawner")
	NetworkManager.server_started.connect( _on_server_started )
	NetworkManager.create_server()
	get_window().title = "Worm Battle [SERVER]"
	NetworkManager.client_connected.connect( _new_player_joined )
	NetworkManager.client_disconnected.connect( _player_left )


func _new_player_joined(peer_id) -> void:
	print("Server spawning a new player")
	var worm = WORM_HEAD.instantiate()
	worm.name = str(peer_id)
	#worm.set_multiplayer_authority(1)
	worm.global_position = Vector2(200,200)
	server_level.add_child(worm)
	
	
func _player_left( peer_id ) -> void:
	for child in server_level.get_children():
		if child.name == str(peer_id):
			child.queue_free()


func _on_server_started() -> void:
	server_level = LEVEL.instantiate()
	get_tree().current_scene.get_node("%MapHost").add_child(server_level)
	multiplayer_spawner.spawn_path = get_tree().current_scene.get_node("%MapHost").get_child(0).get_path()

	#for i in range(5):
	#	var worm = WORM_HEAD.instantiate()
	#	worm.name = "worm_" + str(i)
	#	worm.set_multiplayer_authority(1)
	#	worm.global_position = Vector2( randi_range(100,1000), randi_range(50,600) )
	#	server_level.add_child(worm)	
	#	worms.append(worm)
