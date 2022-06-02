extends Area

var damage : float = 0
var shotSpeed : float = 1
export var g = Vector3.DOWN * 10
var velocity = Vector3.ZERO

func _physics_process(delta):
	velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta

func _ready():
	set_as_toplevel(true)

func destroy ():
	queue_free()

func copy(ammo):
	damage = ammo.damage
	shotSpeed = ammo.shotSpeed


func _on_Timer_timeout():
	destroy()


func _on_Ammo_body_entered(body):
	print("hit")
	destroy()


func _on_Ammo_area_entered(area):
	print("hit area")
	if area.get_parent().is_in_group("Enemy"):
		print("hit enemy")
		area.get_parent().health-=damage
	destroy()
