class_name LeaderBoard
extends VBoxContainer
##
	
## If true then leaderboard will update in real time , otherwise it will
## need to be
@export var is_active: bool = true
	
func _process(_delta: float) -> void:
	if is_active:
		show_leaderboard()
	
	
func clear_leaderboard() -> void:
	for child in get_children():
		child.clear_row()
		
	
func show_leaderboard() -> int:
	clear_leaderboard()
	
	var players = get_sorted_player_list()
	for i in range(players.size()):
		get_child(i).set_player_data(players[i])
	
	# return position of player in this client
	for player in players:
		if player.node_name == str(multiplayer.get_unique_id()):
			return player.position
	
	# somethign wrong...
	return 99
	
## Iterate group of players and get a list sorted in order of player size[br]
## Size is determined by head size + tail
func get_sorted_player_list() -> Array:
	var player_order: Array[Dictionary]
	
	# extract players from the tree and get their name and size data
	for player in get_tree().get_nodes_in_group(Groups.WORM_HEAD):
		var grow_size: int = pow(2,player.grow_value)
		player_order.append( {player_name = player.player_name, node_name = player.name, size = grow_size} )
	
	# sort according to size
	player_order.sort_custom( func(a,b): return a.size >= b.size )	
	
	# add plostion numbers now to the list
	for i in range(player_order.size()):
		player_order[i].position = i+1
		
	return get_filtered_player_list(player_order)
	
	
## Returns list trimmed down to only required number of entries with player as second last
## [param entry_count] Number of items to be in the return list
func get_filtered_player_list( list: Array, entry_count: int = 5 ) -> Array:
	# if list is smaller than required return as is
	if list.size() <= entry_count:
		return list	
	else:
		var my_node: String = str(multiplayer.get_unique_id())
		
		# check if we are in first entry_count - 2 entries, if so return top of list
		for i in range(entry_count - 2):
			if list[i].node_name == my_node:
				return list.slice(0, entry_count)
				
		# go down the list until we find outselves entry_count-1 places ahead, then 
		# return list from current position, gaurenteed to work as we know the list contains
		# at least entry_count + 1 entries 
		var look_ahead = entry_count - 2
		for i in range(list.size() - entry_count + 1):
			if list[i+look_ahead].node_name == my_node:
				# from here, so return a slice of entry count entries from current i index
				return list.slice(i, i + entry_count)

		# return last slice, we are at the end
		return list.slice(list.size() - entry_count, list.size())
	
