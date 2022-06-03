extends Spatial

class_name Body

var projectile : bool
var auto : bool
var rateOfFire : float = 20

var projType = [
	50,
	50,
	25
]

var autoType = [
	50,
	60,
	50
]

var rofType : = [
	[20, 500],
	[10, 50],
	[0,40]
]

func _init(type, subtype):
	var r = randi()%100
	print(r)
	if r < projType[type]:
		projectile = true
	else:
		projectile = false
	
	r = randi()%100
	print(r)
	if r < autoType[type]:
		rateOfFire = rand_range(rofType[type][0],rofType[type][1])
		auto = true
	else:
		auto = false

