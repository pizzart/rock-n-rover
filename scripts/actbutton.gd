extends Button

export var action_icon: Texture

func _ready():
	$Texture.texture = action_icon
	$Name.text = name

func _on_focus_entered():
	$Texture.modulate = Color(10, 10, 10, 1)
	$Name.visible = true

func _on_focus_exited():
	$Texture.modulate = Color(1, 1, 1, 1)
	$Name.visible = false
