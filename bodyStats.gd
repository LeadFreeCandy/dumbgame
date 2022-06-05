extends Resource
class_name bodyStats

var projectile = false
var auto = false
var rateOfFire = 20
var type = 0

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

func _init(t):
	type = t
	var r = randi()%100
	if r < projType[type]:
		projectile = true
	else:
		projectile = false
	
	r = randi()%100
	if r < autoType[type]:
		rateOfFire = rand_range(rofType[type][0],rofType[type][1])
		auto = true
	else:
		auto = false
