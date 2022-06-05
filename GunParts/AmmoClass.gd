extends Node

class_name Ammo

var ammo
var damage
var shotSpeed

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
