extends KinematicBody

var health : int = 25

func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free()
