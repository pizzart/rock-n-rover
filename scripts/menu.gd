extends Control

var exit_focused: bool
var music

func _ready():
	get_node("M/V/V/Play").grab_focus()
	music = Audio.new("res://audio/menu.ogg")
	add_child(music)
	var children = get_node("M/V/V").get_children()
	children.append_array(get_node("M/Settings/V").get_children())
	for child in children:
		child.connect("focus_entered", self, "_on_button_focused")
		child.connect("pressed", self, "_on_button_pressed")
	
	Effect.get_node("ColorRect").material.set_shader_param("amount", 1)
	var mus = AudioServer.get_bus_index("music")
	var sfx = AudioServer.get_bus_index("sound")
	if AudioServer.is_bus_mute(mus):
		get_node("M/Settings/V/Music").modulate = Color.red
	if AudioServer.is_bus_mute(sfx):
		get_node("M/Settings/V/Sounds").modulate = Color.red
	if !Effect.get_node("ColorRect").material.get_shader_param("enabled"):
		get_node("M/Settings/V/Flash").modulate = Color.red

func _physics_process(delta):
	if exit_focused:
		$Mars.rect_scale = $Mars.rect_scale.linear_interpolate(Vector2(), 0.1)
		$Mars.rect_position = $Mars.rect_position.linear_interpolate(Vector2(80, 30), 0.1)
	else:
		$Mars.rect_scale = $Mars.rect_scale.linear_interpolate(Vector2.ONE, 0.1)
		$Mars.rect_position = $Mars.rect_position.linear_interpolate(Vector2(72, 24), 0.1)

func _on_button_focused():
	get_parent().add_child(Audio.new("res://audio/select.wav"))

func _on_button_pressed():
	get_parent().add_child(Audio.new("res://audio/press.wav"))

func _on_exited():
	get_tree().quit()

func _on_exit_focused():
	exit_focused = true

func _on_exit_unfocused():
	exit_focused = false

func _on_played():
	for child in get_node("M/V/V").get_children():
		child.disabled = true
	music.queue_free()
	Transition.phase1 = true
	yield(Transition, "transitioned")
	get_tree().change_scene("res://scenes/World.tscn")

func _on_mute_music():
	var bus_idx = AudioServer.get_bus_index("music")
	AudioServer.set_bus_mute(bus_idx, !AudioServer.is_bus_mute(bus_idx))
	if AudioServer.is_bus_mute(bus_idx):
		get_node("M/Settings/V/Music").modulate = Color.red
	else:
		get_node("M/Settings/V/Music").modulate = Color.green

func _on_mute_sounds():
	var bus_idx = AudioServer.get_bus_index("sound")
	AudioServer.set_bus_mute(bus_idx, !AudioServer.is_bus_mute(bus_idx))
	if AudioServer.is_bus_mute(bus_idx):
		get_node("M/Settings/V/Sounds").modulate = Color.red
	else:
		get_node("M/Settings/V/Sounds").modulate = Color.green

func _on_back():
	get_node("M/V").visible = true
	get_node("M/Settings").visible = false
	get_node("M/V/V/Play").grab_focus()

func _on_flash():
	Effect.get_node("ColorRect").material.set_shader_param("enabled", \
			!Effect.get_node("ColorRect").material.get_shader_param("enabled"))
	Effect.get_node("Vignette").visible = !Effect.get_node("Vignette").visible
	if Effect.get_node("ColorRect").material.get_shader_param("enabled"):
		get_node("M/Settings/V/Flash").modulate = Color.green
	else:
		get_node("M/Settings/V/Flash").modulate = Color.red

func _on_settings():
	get_node("M/V").visible = false
	get_node("M/Settings").visible = true
	get_node("M/Settings/V/Flash").grab_focus()
