class_name Bootstrap
extends Node

const MULTIPLAYER_HOST = preload("uid://dkfiy1cunmvyk")
const HOST_SERVER = preload("uid://b2dbm01fqbchm")
const MAIN = preload("uid://ni2vi3eh5aa4")

## hold a global reference to node into which we can place maps
static var map_host: Node

## global ref to the spawner so we can set the correct spawn path
static var multiplayer_spawner: MultiplayerSpawner


func _ready() -> void:
	boot_game()
	
	
func boot_game() -> void:
	map_host = %MapHost
	multiplayer_spawner = %MultiplayerSpawner
	
	if "--server" in OS.get_cmdline_args() or OS.has_feature("server"):
		add_child( HOST_SERVER.instantiate()  )
	elif "--game" in OS.get_cmdline_args():
		add_child( MULTIPLAYER_HOST.instantiate()  )
	else:
		add_child( MAIN.instantiate()  )
