extends KinematicBody

var health : int = 25

func _process(delta):
	if health <= 0:
		queue_free()
