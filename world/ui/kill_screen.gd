extends ColorRect
## Hosts a fade label, so we need to handle our own visiblitt so the label 
## animation can be started


@onready var killed_label: FadingLabel = $KilledLabel


func _ready() -> void:
	visibility_changed.connect( _on_visibility_changed )
	visible = false
	
	
func _on_visibility_changed() -> void:
	killed_label.visible = true
