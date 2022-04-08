extends ParallaxLayer

var RNG = RandomNumberGenerator.new()

func _draw():
	RNG.randomize()
	draw_rect(Rect2(Vector2(0, 0), Vector2(150, 100)), Color("#010005"))
	for i in range(100):
		draw_circle(Vector2(RNG.randf_range(0, 144), RNG.randf_range(0, 96)), 0.5, Color.silver)

func _physics_process(delta):
	motion_offset += Vector2.ONE * 0.0001
