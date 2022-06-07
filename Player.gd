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

var inInventory = false

var gun

onready var pivot = $Pivot
onready var inventory = $Inventory
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
	inventory.addPart(gun.body.stats)
	inventory.addPart(gun.grip.stats)
	inventory.addPart(gun.stock.stats)
	if gun.body.stats.projectile:
		crosshair.texture = load("res://crosshair_proj.png")

func _process(delta):
	if Input.is_action_just_pressed("shoot") and not inInventory:
		gun.shoot(aimcast)
	elif Input.is_action_pressed("shoot") and gun.body.stats.auto and not inInventory:
		gun.shoot(aimcast)
	

	
	if Input.is_action_just_pressed("interact"):
		if reach.is_colliding():
			if reach.get_collider().is_in_group("gun"):
				hand.remove_child(gun)
				reach.get_collider().get_parent().add_child(gun)
				gun = reach.get_collider()
				gun.get_parent().remove_child(gun)
				hand.add_child(gun)
				gun.global_transform = hand.global_transform
				inventory.setPart(0,gun.body.stats)
				inventory.setPart(1,gun.grip.stats)
				inventory.setPart(2,gun.stock.stats)
				if gun.body.stats.projectile:
					crosshair.texture = load("res://crosshair_proj.png")
				else:
					crosshair.texture = load("res://crosshair.png")
			elif reach.get_collider().is_in_group("part"):
				print("added part")
				inventory.addItem(reach.get_collider().stats)
				reach.get_collider().queue_free()
				print(inventory.itemList.back())
	if Input.is_action_just_pressed("inventory"):
		inventory.visible = !inventory.visible
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			inInventory = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			inInventory = true


func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(-1*event.relative.x)*lookSensitivity)
		pivot.rotate_x(deg2rad(event.relative.y)*lookSensitivity)
		pivot.rotation.x = clamp(pivot.rotation.x, deg2rad(minLookAngle), deg2rad(maxLookAngle))
		
	if event.is_action_pressed("shoot"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and not inInventory:
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
			vector *= 200
		if Input.is_action_pressed("ads"):
			vector /= 2
		
		
		return vector

func take_damage(amount):
	health -= amount
	print(health)


func _on_ItemList_item_activated(index):
	match(inventory.itemList[index].id):
		"Body":
			var temp = gun.body.stats
			gun.body.stats = inventory.itemList[index]
			inventory.itemList[index] = temp
			inventory.setPart(0,gun.body.stats)
			inventory.setItem(index,temp)
			gun.bodyMod.setMaterial(gun.body.stats.material)
			if gun.body.stats.projectile:
				crosshair.texture = load("res://crosshair_proj.png")
			else:
				crosshair.texture = load("res://crosshair.png")
		"Grip":
			var temp = gun.grip.stats
			gun.grip.stats = inventory.itemList[index]
			inventory.itemList[index] = temp
			inventory.setPart(1,gun.grip.stats)
			inventory.setItem(index,temp)
			gun.gripMod.setMaterial(gun.grip.stats.material)
		"Stock":
			var temp = gun.stock.stats
			gun.stock.stats = inventory.itemList[index]
			inventory.itemList[index] = temp
			inventory.setPart(2,gun.stock.stats)
			inventory.setItem(index,temp)
			gun.stockMod.setMaterial(gun.stock.stats.material)
