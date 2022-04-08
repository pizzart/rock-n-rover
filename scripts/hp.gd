extends Label

var battlers
var idx: int

func upd_hp():
	text = "%s/%s" % [battlers[idx][0], battlers[idx][1]]
	rect_position = Vector2(-text.length() * 6 / 2, 8)
