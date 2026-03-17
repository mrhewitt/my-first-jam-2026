extends HBoxContainer


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
	player_position_label.text = str(player_data.position)
	player_name_label.text = player_data.player_name
	player_score_label.text = str( player_data.size ) 
	
