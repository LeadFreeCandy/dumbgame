extends RigidBody

var damage : float = 0
var shotSpeed : float = 1

func _ready():
	set_as_toplevel(true)

func destroy ():
	queue_free()

func _on_Ammo_area_entered(body):
	if body.is_in_group("Enemy"):
		body.health-=damage
	destroy()

func copy(ammo):
	damage = ammo.damage
	shotSpeed = ammo.shotSpeed


func _on_Timer_timeout():
	destroy()
