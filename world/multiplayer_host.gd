extends GameScene

const LEVEL = preload("uid://d2ufjf8lvutq6")

@onready var multiplayer_spawner: MultiplayerSpawner  
@onready var connecting_label: Label = $ConnectingLabel
@onready var connection_lost_label: Label = $ConnectionLostLabel

var level_instance: Node2D


func _ready() -> void:
	multiplayer_spawner = get_tree().current_scene.get_node("%MultiplayerSpawner")
	connect_server()


func connect_server() -> void:
	await get_tree().create_timer(3).timeout
	NetworkManager.client_connected.connect(_on_connected)
	NetworkManager.server_connection_lost.connect(_on_disconnected)
	NetworkManager.connect_to_server()
	
	
func _on_connected(peer_id: int) -> void:
	connecting_label.visible = false
	level_instance = LEVEL.instantiate()
	get_tree().current_scene.get_node("%MapHost").add_child(level_instance)
	multiplayer_spawner.spawn_path = get_tree().current_scene.get_node("%MapHost").get_child(0).get_path()


func _on_disconnected() -> void:
	connection_lost_label.visible = true
	level_instance.queue_free()
