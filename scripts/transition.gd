extends CanvasLayer

signal transitioned
const FAST = 1.2
const SLOW = 1.042
var speed: float = FAST
var phase1: bool
var phase2: bool

func _physics_process(delta):
	if phase1:
		$ColorRect.material.set_shader_param("circle_size", $ColorRect.material.get_shader_param("circle_size") / speed)
		if $ColorRect.material.get_shader_param("circle_size") <= 0.005:
			phase1 = false
			phase2 = true
			emit_signal("transitioned")
	if phase2:
		$ColorRect.material.set_shader_param("circle_size", $ColorRect.material.get_shader_param("circle_size") * FAST)
		if $ColorRect.material.get_shader_param("circle_size") >= 1.1:
			phase2 = false
