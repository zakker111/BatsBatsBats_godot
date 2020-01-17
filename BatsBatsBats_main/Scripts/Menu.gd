extends Control
#Note some graphical bugs occure when using main menu and they occure whit out main menu too dunno why
#in inspector is scene_to_load this loads that scene in this case level scene
export (String) var scene_to_load
var level
onready var levelscene = load(scene_to_load)

func _ready():
	#change color of background
	VisualServer.set_default_clear_color(Color(0.0,0.0,0.0,0.0))

#when play is pressed this signal is connected from inspector
func _on_TextureButton_pressed() -> void:
	level = levelscene.instance()
	get_node("/root/Main").add_child(level)
	#free menu from memory 
	queue_free()

