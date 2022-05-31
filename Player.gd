extends KinematicBody

var damage : int = 5

var moveSpeed : float = 3.0
var jumpForce : float = 3.0
var gravity : float = 10

var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 0.1

var input_move : Vector3 = Vector3()
var gravity_local : Vector3 = Vector3()
var snap : Vector3 = Vector3()

onready var pivot = $Pivot
onready var aimcast = $Pivot/Camera/aimcast
onready var bang = $Pivot/Bang
onready var crosshair = $Pivot/Camera/CrossHair
onready var impact = preload("res://BulletImpact.tscn")

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		shoot()

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


func shoot():
	#bang.play()
	if aimcast.is_colliding():
		var target = aimcast.get_collider()
		var impact_pos = aimcast.get_collision_point()
		
		var bullet_impact = impact.instance()

#		get_node("/root/MainLevel").add_child(bullet_impact)
		target.add_child(bullet_impact)
		
#		bullet_impact.translation = impact_pos
		bullet_impact.global_transform = bullet_impact.transform.translated(impact_pos)
		print(bullet_impact.translation)



		
		print(impact_pos)
		if target.is_in_group("Enemy"):
			print("hit enemy")
			target.health -= damage




func _on_Hand_off_ads():
	crosshair.visible = true


func _on_Hand_on_ads():
	crosshair.visible = false
