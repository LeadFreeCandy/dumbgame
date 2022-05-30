extends KinematicBody

var moveSpeed : float = 3.0
var jumpForce : float = 3.0
var gravity : float = 10

var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 0.5

var mouseDelta : Vector2 = Vector2()
var input_move : Vector3 = Vector3()
var gravity_local : Vector3 = Vector3()

onready var pivot = get_node("Pivot")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative

func _process(delta):
	
	pivot.rotation_degrees += Vector3(rad2deg(mouseDelta.y), 0, 0) * lookSensitivity * delta
	pivot.rotation_degrees.x = clamp(pivot.rotation_degrees.x, minLookAngle, maxLookAngle)
	rotation_degrees -= Vector3(0, rad2deg(mouseDelta.x), 0) * lookSensitivity * delta
	mouseDelta = Vector2()

func _physics_process(delta):
	input_move = get_input_direction()*moveSpeed
	
	if not is_on_floor():
		gravity_local += gravity * Vector3.DOWN * delta
	else:
		gravity_local = gravity * -get_floor_normal() * delta
	
	if(Input.is_action_just_pressed("jump")):
		gravity_local = Vector3.UP * jumpForce
	
	move_and_slide(input_move+gravity_local, Vector3.UP)


func get_input_direction() -> Vector3:
		var z : float = (
			Input.get_action_strength("forward") - Input.get_action_strength("backward")
		)
		var x : float = (
			Input.get_action_strength("left") - Input.get_action_strength("right")
		)
		return transform.basis.xform(Vector3(x, 0, z)).normalized()
