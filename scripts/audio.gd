class_name Audio
extends AudioStreamPlayer

var next: String

func _init(path: String, n: String = ""):
	stream = load(path)
	autoplay = true
	if path.ends_with("ogg"):
		bus = "music"
	elif path.ends_with("wav"):
		bus = "sound"
	if !n.empty():
		next = n
	connect("finished", self, "_on_finished")

func _on_finished():
	if !next.empty():
		stream = load(next)
		if next.ends_with("ogg"):
			bus = "music"
		elif next.ends_with("wav"):
			bus = "sound"
		play()
		next = ""
	else:
		queue_free()
