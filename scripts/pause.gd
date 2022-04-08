extends Control

var mus_paused: bool

func _input(event):
	if event.is_action_pressed("pause"):
		pause()

func pause():
	if get_tree().current_scene.name == "World":
		if !get_tree().paused:
			mus_paused = get_tree().current_scene.get_node("Music").stream_paused
		visible = !visible
		get_tree().paused = !get_tree().paused
		if !get_tree().paused and mus_paused:
			get_tree().current_scene.get_node("Music").stream_paused = true
