extends KinematicBody

var moveSpeed : float = 3.0
var jumpForce : float = 3.0
var gravity : float = 10

var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 0.1

var input_move : Vector3 = Vector3()
var gravity_local : Vector3 = Vector3()
var snap : Vector3 = Vector3()

onready var pivot = get_node("Pivot")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-1*event.relative.x)*lookSensitivity)
		pivot.rotate_x(deg2rad(event.relative.y)*lookSensitivity)
		pivot.rotation.x = clamp(pivot.rotation.x, deg2rad(minLookAngle), deg2rad(maxLookAngle))

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
