extends Area

var stats

var g = Vector3.DOWN * 10
var velocity = Vector3.ZERO

func _ready():
	set_as_toplevel(true)

func _physics_process(delta):
	velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta

func destroy ():
	queue_free()

func _on_Timer_timeout():
	destroy()


func _on_Ammo_body_entered(body):
	destroy()


func _on_Ammo_area_entered(area):
	if area.get_parent().is_in_group("Enemy"):
		area.get_parent().health-= stats.damage
	destroy()
