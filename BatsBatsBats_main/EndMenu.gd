extends Control
#Note some graphical bugs occure when using main menu and they occure whit out main menu too dunno why
var KillCounter

func _ready():
	KillCounter = get_node("CenterContainer/VBoxContainer/Label3")
	#change color of background black
	VisualServer.set_default_clear_color(Color(0.0,0.0,0.0,0.0))

#when play is pressed this signal is connected from inspector
func _on_TextureButton_pressed() -> void:
	#reload game
	get_tree().reload_current_scene()

#ubdate killcount label
func _do_update_kill_count_label(ammount) -> void:
	KillCounter.text = str(ammount)