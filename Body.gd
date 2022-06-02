extends Spatial

class_name Body

var projectile : bool
var auto : bool

var projType = [
	50,
	50,
	25
]

var autoType = [
	10,
	60,
	50
]

func _init(type, subtype):
	var r = randi()%100
	if r < projType[type]:
		projectile = true
	else:
		projectile = false
	
	r = randi()%100
	if r < autoType[type]:
		auto = true
	else:
		auto = false
	
