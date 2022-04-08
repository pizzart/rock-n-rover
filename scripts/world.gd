extends Node2D

signal battle_started
signal battle_ended
signal turn_changed
signal lab_entered

const REQUIRED = 6
var music
var fighting: bool
var turn: int
var hud
var stability: float = 1
var current: int
var place = "Mars"
var zooming_out: bool

var RoverBattle = preload("res://scenes/RoverBattle.tscn")
var AlienBattle = preload("res://scenes/AlienBattle.tscn")
var PeyeramidBattle = preload("res://scenes/PeyeramidBattle.tscn")
var RoboBattle = preload("res://scenes/RoboBattle.tscn")
var WireBattle = preload("res://scenes/WireBattle.tscn")
var SkeleBattle = preload("res://scenes/SkeleBattle.tscn")
var UFOBattle = preload("res://scenes/UFOBattle.tscn")
var HUD = preload("res://scenes/HUD.tscn")
var HP = preload("res://scenes/HP.tscn")
var RNG = RandomNumberGenerator.new()

# max hp, attack, defense
var battlers = [
	[100, 9, 4, RoverBattle, Color("#588dbe")],
	[50, 10, 3, AlienBattle, Color("#328464")],
	[70, 9, 4, PeyeramidBattle, Color("#8e5252")],
	[60, 12, 5, RoboBattle, Color("#dae0ea")],
	[40, 20, 5, WireBattle, Color("#143464")],
	[55, 10, 3, SkeleBattle, Color("#e4d2aa")],
	[150, 10, 5, UFOBattle, Color("#ff0000")],
]
var current_battlers = []
var battler_places = {
	"Mars": [1, 2, 5],
	"Lab": [1, 3, 4, 5]
}
var order = [1, 5, 2, 4, 3]
var kill_count: int

onready var camera = get_node("RoverOverworld/Camera")

func _ready():
	RNG.randomize()
	connect("battle_started", self, "_on_battle_started")
	connect("battle_ended", self, "_on_battle_ended")
	connect("turn_changed", self, "_on_turn_changed")
	connect("lab_entered", self, "_on_lab_entered")
	get_node("Map/Collision").polygon = get_node("Map/Polygon").polygon

func _physics_process(delta):
	if zooming_out:
		camera.zoom = camera.zoom.linear_interpolate(Vector2.ONE * 3, 0.1)
	else:
		camera.zoom = camera.zoom.linear_interpolate(Vector2.ONE, 0.2)
	$Arrow.position = $RoverOverworld.position + $RoverOverworld.position.direction_to($FinalBossTrig.position) * 30
	$Arrow.look_at($FinalBossTrig.position)

func upd_stability(add: float, malicious: bool):
	var color = Color.red
	if add > 0:
		color = Color.cyan
	Effect.get_node("Vignette").color = color
	Effect.get_node("Vignette").modulate.a = 1
	if stability + add > 0:
		stability = clamp(stability + add, 0, 1)
		Effect.get_node("ColorRect").material.set_shader_param("amount", stability)
		$Noise.volume_db = clamp(-stability * 100 + 10, -80, -10)
		$StabilityLayer/M/P/V/Text.text = "STABILITY: " + str(stability * 100) + "%"
		$StabilityLayer/M/P/V/Bar.value = stability * 100
		$StabilityLayer/M/P/V/Bar.modulate = Color(1.0 - stability, stability, 0.5)
		return true
	elif malicious:
		Transition.speed = Transition.FAST
		Transition.phase1 = true
		yield(Transition, "transitioned")
		get_tree().change_scene("res://scenes/Menu.tscn")
	else:
		return false

func end_turn():
	if turn == 0:
		hud.get_node("HUD").visible = false
		turn = current
	else:
		hud.get_node("HUD").visible = true
		hud.get_node("HUD").focus()
		turn = 0
	emit_signal("turn_changed")

func deal_damage(attacker: int, attacked: int):
	if attacker == 0:
		if RNG.randf_range(0, 1) > stability:
			add_child(Audio.new("res://audio/fail.wav"))
			end_turn()
			return
	add_child(Audio.new("res://audio/attack.wav"))
	current_battlers[attacked][0] -= max(current_battlers[attacker][2] - \
			current_battlers[attacked][3] * current_battlers[attacked][7], 0)
	if attacked == 0:
		upd_stability(-0.05, true)
		if current_battlers[0][0] <= current_battlers[0][1] / 4 and current_battlers[0][0] > 0:
				add_child(Audio.new("res://audio/lowhp.wav"))
	if current_battlers[attacked][0] <= 0:
		var pos = true
		if attacked == 0:
			upd_stability(-0.4, true)
			add_child(Audio.new("res://audio/die.wav"))
			pos = false
		emit_signal("battle_ended", pos)
		return
	current_battlers[attacked][5].get_node("HP").upd_hp()
	current_battlers[attacked][5].get_node("Damage").frame = 0
	current_battlers[attacked][5].get_node("Damage").play()
	current_battlers[turn][7] = 1
	current_battlers[turn][5].get_node("Shield").visible = false
	end_turn()

func block_damage(defender: int):
	if defender == 0:
		upd_stability(0.1, false)
	add_child(Audio.new("res://audio/block.wav"))
	current_battlers[defender][5].get_node("Shield").visible = true
	current_battlers[defender][7] = 2
	end_turn()

func flee():
	if RNG.randf_range(0, 0.95) < stability:
		if upd_stability(-0.05, false):
			add_child(Audio.new("res://audio/flee.wav"))
			emit_signal("battle_ended", false)
	else:
		add_child(Audio.new("res://audio/fail.wav"))
		upd_stability(-0.1, true)
		end_turn()

func heal(idx: int):
	if idx == 0:
		if !upd_stability(-0.1, false):
			return
	add_child(Audio.new("res://audio/heal.wav"))
	current_battlers[idx][0] = min(current_battlers[idx][0] + 5, current_battlers[idx][1])
	current_battlers[idx][5].get_node("HP").upd_hp()
	current_battlers[idx][5].self_modulate = Color("#793a80")
	yield(get_tree().create_timer(0.2), "timeout")
	current_battlers[idx][5].self_modulate = Color.white
	end_turn()

func _on_battle_started():
	fighting = true
	
	hud = HUD.instance()

	var idx
	if kill_count >= REQUIRED and place == "Lab":
		idx = 6
		hud.get_node("HUD/V/Flee").visible = false
		$Tint.visible = true
		$BG/Tint.visible = true
	elif kill_count >= order.size():
		idx = battler_places[place][RNG.randi() % battler_places[place].size()]
	else:
		idx = order[kill_count]
	
	$RoverOverworld.controllable = false
	$Music.stream_paused = true
	yield(get_tree().create_timer(0.2), "timeout")
	add_child(Audio.new("res://audio/select.wav"))
	yield(get_tree().create_timer(0.2), "timeout")
	add_child(Audio.new("res://audio/select.wav"))
	yield(get_tree().create_timer(0.2), "timeout")
	add_child(Audio.new("res://audio/select.wav"))
	yield(get_tree().create_timer(0.3), "timeout")
	
	
	Transition.speed = Transition.SLOW
	Transition.phase1 = true
	music = Audio.new("res://audio/battle_enter.wav", "res://audio/battle.ogg")
	add_child(music)
	yield(music, "finished")
	
	$RoverOverworld.remove_child(camera)
	add_child(camera)
	camera.position = Vector2(72, 48)
	camera.reset_smoothing()
	
	$RoverOverworld.visible = false
	get_node("BG/Sprite").visible = true
	get_node("BG/Parallax/" + place).visible = false
	
	add_child(hud)
	
	current = idx
	current_battlers = battlers.duplicate(true)
	for i in range(battlers.size()):
		if i == 0 or i == idx:
			current_battlers[i].push_front(battlers[i][0])
			current_battlers[i].push_back(1)
			current_battlers[i].insert(5, battlers[i][3].instance())
			add_child(current_battlers[i][5])
			current_battlers[i][5].add_child(HP.instance())
			if place == "Lab":
				current_battlers[i][5].get_node("Shadow").modulate = Color.white
			var hp = current_battlers[i][5].get_node("HP")
			hp.battlers = current_battlers
			hp.idx = i
			hp.add_color_override("font_color", battlers[i][4])
			hp.upd_hp()

func _on_battle_ended(positive: bool):
	fighting = false
	
	for child in hud.get_node("HUD/V").get_children():
		child.disabled = true
	
	music.emit_signal("finished")
	if positive:
		yield(get_tree().create_timer(0.1), "timeout")
		current_battlers[current][5].queue_free()
		add_child(Audio.new("res://audio/win.wav"))
		hud.get_node("HUD/HP/Anim").play("move")
		yield(hud.get_node("HUD/HP/Anim"), "animation_finished")
	else:
		current_battlers[0][5].queue_free()
	
	Transition.speed = Transition.FAST
	Transition.phase1 = true
	yield(Transition, "transitioned")
	
	$RoverOverworld.controllable = true
	$RoverOverworld.visible = true

	if positive:
		current_battlers[0][5].queue_free()

		if current == 6:
			get_tree().change_scene("res://scenes/End.tscn")
		
		kill_count += 1
		if kill_count >= REQUIRED:
			$RoverOverworld.can_battle = false
			if place == "Lab":
				$StabilityLayer/M/Left/Text.text = "follow the arrow!"
				$Arrow.visible = true
			else:
				$StabilityLayer/M/Left/Text.text = "enter the lab!"
		else:
			$StabilityLayer/M/Left/Text.text = str(REQUIRED - kill_count) + " ENEMIES LEFT"
		upd_stability(0.2, false)
		battlers[0][0] += 3
		battlers[0][1] += 1
	else:
		current_battlers[current][5].queue_free()

	remove_child(camera)
	$RoverOverworld.add_child(camera)
	camera.global_position = $RoverOverworld.position
	camera.reset_smoothing()
	
	get_node("BG/Sprite").visible = false
	get_node("BG/Parallax/" + place).visible = true
	hud.queue_free()
	
	if !positive:
		yield(get_tree().create_timer(0.5), "timeout")
	$Music.stream_paused = false

func _on_turn_changed():
	if turn != 0:
		yield(get_tree().create_timer(0.5), "timeout")
		var choice = RNG.randf_range(0, 1)
		if choice <= 0.6:
			deal_damage(turn, 0)
		elif choice <= 0.9:
			block_damage(turn)
		elif choice <= 1:
			if current_battlers[turn][0] <= current_battlers[turn][1] / 2:
				heal(turn)
			else:
				block_damage(turn)

func _on_lab_entered():
	place = "Lab"
	get_node("BG/Sprite").animation = "lab"
	get_node("BG/Parallax/Mars").visible = false
	get_node("BG/Parallax/Lab").visible = true
	$ZoomOutTrig.queue_free()
	$LabEnterTrig.queue_free()
	$Map.queue_free()
	if kill_count >= REQUIRED:
		$StabilityLayer/M/Left/Text.text = "follow the arrow!"
		$Arrow.visible = true

func _on_trig1(body):
	if body is KinematicBody2D:
		body.can_battle = false
		zooming_out = true

func _on_trig1_exited(body):
	if body is KinematicBody2D:
		body.can_battle = true
		zooming_out = false

func _on_trig2(body):
	if body is KinematicBody2D:
		Transition.speed = Transition.FAST
		Transition.phase1 = true
		yield(Transition, "transitioned")
		emit_signal("lab_entered")

func _on_trig3(body):
	if body is KinematicBody2D:
		if kill_count >= REQUIRED:
			if !$Music.stream_paused:
				emit_signal("battle_started")
