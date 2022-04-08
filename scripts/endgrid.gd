extends Node2D

var times_x = [0.2, 0.05, 0.05, 1.8, 0.05, 0.05, 1.8, 0.05, 0.05, 1.8, 0.05, 0.05, 1.8, 0.05, 0.05, 1.8, 0.05, 0.05, 1.8]
var times_y = [0.05, 0.05, 1.8, 0.05, 0.05, 0.8, 0.8, 0.5, 1.8]
var y: bool
var current = 0
var done: bool
var color = Color("#0a0320")

func _ready():
	for x in range(18):
		yield(get_tree().create_timer(times_x[x]), "timeout")
		current = x
		update()
	current = 0
	y = true
	for y in range(13):
		if y < times_y.size():
			yield(get_tree().create_timer(times_y[y]), "timeout")
		current = y
		update()
	color = Color("#8e4965")
	update()
	done = true

func _draw():
	draw_rect(Rect2(0, 0, 144, 96), Color("#170E33"))
	if !y:
		for x in range(current):
			draw_line(Vector2(x * 8 + 8, 0), Vector2(x * 8 + 8, 96), color)
	else:
		for x in range(18):
			draw_line(Vector2(x * 8, 0), Vector2(x * 8, 96), color)
		for y in range(current):
			draw_line(Vector2(0, y * 8), Vector2(144, y * 8), color)

func _physics_process(delta):
	if done:
		get_parent().motion_offset += Vector2.ONE * 0.1
