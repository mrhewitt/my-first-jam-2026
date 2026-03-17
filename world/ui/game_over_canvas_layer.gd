extends CanvasLayer


@onready var position_label: Label = $MaskColorRect/PositionLabel
@onready var leader_board: LeaderBoard = $MaskColorRect/LeaderBoard
@onready var continue_button: Button = $MaskColorRect/ContinueButton


## Prepares player leader board and position so we have these saved [br]
## for display after killed event ends and player is removed by server
func prepare_game_over() -> void:
	position_label.text = "#" + str( leader_board.show_leaderboard() )
