extends KinematicBody

var health = 10

var moveSpeed : float = 3.0
var jumpForce : float = 3.0
var gravity : float = 10

var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 0.1

var input_move : Vector3 = Vector3()
var gravity_local : Vector3 = Vector3()
var snap : Vector3 = Vector3()

var gun

onready var pivot = $Pivot
onready var aimcast = $Pivot/Camera/aimcast
onready var bang = $Pivot/Bang
onready var reach = $Pivot/Camera/reach
onready var hand = $Pivot/Hand
onready var crosshair = $Pivot/Camera/CrossHair
onready var gunScene = preload("res://Rifle.tscn")


func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	gun = gunScene.instance()
	hand.add_child(gun)
	if gun.body.stats.projectile:
		crosshair.texture = load("res://crosshair_proj.png")

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		gun.shoot(aimcast)
	elif Input.is_action_pressed("shoot") and gun.body.stats.auto:
		gun.shoot(aimcast)
	
	if Input.is_action_just_pressed("interact"):
		if reach.is_colliding() and reach.get_collider().is_in_group("gun"):
			hand.remove_child(gun)
			reach.get_collider().get_parent().add_child(gun)
			gun = reach.get_collider()
			gun.get_parent().remove_child(gun)
			hand.add_child(gun)
			gun.global_transform = hand.global_transform
			ResourceSaver.save("res://ammoSave.tres", gun.ammo)
			if gun.body.stats.projectile:
				crosshair.texture = load("res://crosshair_proj.png")
			else:
				crosshair.texture = load("res://crosshair.png")

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(-1*event.relative.x)*lookSensitivity)
		pivot.rotate_x(deg2rad(event.relative.y)*lookSensitivity)
		pivot.rotation.x = clamp(pivot.rotation.x, deg2rad(minLookAngle), deg2rad(maxLookAngle))
		
	if event.is_action_pressed("shoot"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	input_move = get_input_direction()*moveSpeed
	
	if not is_on_floor():
		gravity_local += gravity * Vector3.DOWN * delta
	else:
		gravity_local = Vector3.ZERO
	
	snap = Vector3.DOWN
	if is_on_floor():
		snap = -get_floor_normal()
	
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap = Vector3.ZERO
		gravity_local = Vector3.UP * jumpForce
	
	move_and_slide_with_snap(input_move+gravity_local, snap, Vector3.UP)


func get_input_direction() -> Vector3:
		var z : float = (
			Input.get_action_strength("forward") - Input.get_action_strength("backward")
		)
		var x : float = (
			Input.get_action_strength("left") - Input.get_action_strength("right")
		)

		var vector = transform.basis.xform(Vector3(x, 0, z)).normalized()
		
		if Input.is_action_pressed("sprint"):
			vector *= 2
		
		return vector

func take_damage(amount):
	health -= amount
	print(health)

