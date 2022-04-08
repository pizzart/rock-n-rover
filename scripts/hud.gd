extends Control

func _ready():
	focus()
	for child in $V.get_children():
		child.connect("focus_entered", self, "_on_button_focused")

func focus():
	get_node("V/Attack").grab_focus()

func _on_button_focused():
	get_parent().add_child(Audio.new("res://audio/select.wav"))

func _on_attacked():
	get_tree().current_scene.deal_damage(0, get_tree().current_scene.current)

func _on_defended():
	get_tree().current_scene.block_damage(0)

func _on_fled():
	get_tree().current_scene.flee()

func _on_healed():
	get_tree().current_scene.heal(0)
