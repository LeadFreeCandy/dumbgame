extends Resource
class_name ammoStats

var damage = 10.0
var shotSpeed = 10.0
var material

var dmgType = [
	[10, 50],
	[10, 50],
	[15,75]
]

var shotType= [
	[25,25],
	[25,25],
	[25,25]
]

func _init(type):
	damage = rand_range(dmgType[type][0],dmgType[type][1])
	shotSpeed = rand_range(shotType[type][0],shotType[type][1])
	material = SpatialMaterial.new()
	material.albedo_color = Color(randf(),randf(),randf())
