extends HBoxContainer

const PLAYER_LB_LABEL_SETTINGS = preload("uid://cc2il80h6db4u")

@onready var player_position_label: Label = $PlayerPositionLabel
@onready var player_name_label: Label = $PlayerNameLabel
@onready var player_score_label: Label = $PlayerScoreLabel


func _ready() -> void:
	clear_row()

func clear_row() -> void:
	player_position_label.text = ""
	player_name_label.text = ""
	player_score_label.text = ""


func set_player_data( player_data: Dictionary ) -> void:
	# if this is the player on this client highlight his name
	if str(multiplayer.get_unique_id()) == player_data.node_name:
		player_position_label.label_settings = PLAYER_LB_LABEL_SETTINGS
		player_name_label.label_settings = PLAYER_LB_LABEL_SETTINGS
		player_score_label.label_settings = PLAYER_LB_LABEL_SETTINGS
	else:
		player_position_label.label_settings = null
		player_name_label.label_settings = null
		player_score_label.label_settings = null

	player_position_label.text = str(player_data.position) + "."
	player_name_label.text = player_data.player_name
	player_score_label.text = str( player_data.size ) 
	
