extends KinematicBody2D

const SPEED = 50
var direction: Vector2 = Vector2.RIGHT
var velocity: Vector2
var total_distance: float
var distance_driven: float
var distance_required: float
var prev: Vector2
var controllable: bool = true
var can_battle: bool = true
var point: Vector2
var drag: bool
var RNG = RandomNumberGenerator.new()

func _ready():
	RNG.randomize()
	distance_required = RNG.randi_range(600, 900)

func _input(event):
	if event is InputEventScreenTouch:
		drag = event.pressed
		point = position + event.position - Vector2(144, 96) / 2

func _physics_process(delta):
	if controllable:
		if drag:
			direction = position.direction_to(point)
			if position.distance_to(point) < 1:
				point = Vector2.ZERO
		else:
			point = Vector2.ZERO
			direction = direction.rotated((Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) / 20)

		velocity = direction * SPEED
		if !point:
			velocity *= Input.get_action_strength("move_up")
		velocity = move_and_slide(velocity)
		distance_driven += prev.distance_to(position)
		prev = position
		if velocity:
			if distance_driven >= distance_required and can_battle:
				total_distance += distance_driven
				distance_driven = 0
				distance_required = RNG.randi_range(150, 300)
				
				get_parent().emit_signal("battle_started")
			if !$Audio.playing:
				$Audio.play()
		else:
			$Audio.stop()
		rotation = lerp_angle(rotation, direction.angle(), 0.2)
	else:
		$Audio.stop()
