extends KinematicBody

var health : int = 50
var moveSpeed : float = 1.0
var damage : int = 1
var attackRate : float = 1.0
var attackDist : float = 2.0

onready var player : Node = get_node("/root/MainLevel/Player")
onready var timer : Timer = get_node("Timer")

func _ready():
	timer.set_wait_time(attackRate)
	timer.start()

func _process(delta):
	var dir = (player.translation - translation).normalized()
	dir.y = 0
	move_and_slide(dir*moveSpeed, Vector3.UP)
	
	if health <= 0:
		queue_free()


func _on_Timer_timeout():
	if translation.distance_to(player.translation) <= attackDist:
		attack() 

func attack ():
	player.take_damage(damage)
