extends Node


onready var gun = preload("res://Rifle.tscn")

func _ready():
	var g = gun.instance()
	var g2 = gun.instance()
	var g3 = gun.instance()
	$gunSpawn.add_child(g)
	$gunSpawn2.add_child(g2)
	$gunSpawn3.add_child(g3)
	

