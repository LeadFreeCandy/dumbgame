extends KinematicBody


var health = 50

func _process(delta):
	if health <= 0:
		queue_free()


