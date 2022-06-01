extends KinematicBody

var damage : float = 0
var shotSpeed : float = 1
var force = 5.0
var g = 10 * Vector3.DOWN
var local_gravity = Vector3()
var vel = Vector3()
var hit

func _ready():
	vel += -transform.basis.z * force

func _physics_process(delta):
	vel += g * delta * shotSpeed
	look_at(transform.origin + vel.normalized(), Vector3.UP)
	hit = move_and_collide(vel*delta*shotSpeed)
	if hit:
		if hit.has_method("take_damage"):
			hit.take_damage(damage)
			destroy()

func destroy ():
	queue_free()

func _on_Ammo_area_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	destroy()

func copy(ammo):
	damage = ammo.damage
	force = ammo.shotSpeed


func _on_Timer_timeout():
	destroy()
