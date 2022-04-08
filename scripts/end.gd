extends Control

func _ready():
	add_child(Audio.new("res://audio/ending.ogg"))
	yield(get_tree().create_timer(0.2), "timeout")
	$Text/A.play("appear")
	yield(get_tree().create_timer(1.85), "timeout")
	$Credits/A.play("appear")
	yield(get_tree().create_timer(1.85), "timeout")
	$Pib/A.play("appear")
	yield(get_tree().create_timer(1.85), "timeout")
	$TSSG/A.play("appear")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
