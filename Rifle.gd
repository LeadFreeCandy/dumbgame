extends Spatial

onready var bodyMod = preload("res://Body.tscn")
onready var gripMod = preload("res://Grip.tscn")
onready var stockMod = preload("res://Stock.tscn")
onready var impact = preload("res://BulletImpact.tscn")
onready var am = preload("res://Ammo.tscn")

var body
var grip
var stock
var ammo

var recoil_x
var recoil_y
var ergo

func _ready():
	randomize()
	body = Body.new(0, 0)
	grip = Grip.new(0, 0)
	stock = Stock.new(0, 0)
	ammo = Ammo.new(0, 0)
	
	
	ergo = grip.ergo + stock.ergo
	recoil_x = grip.recoil_x + stock.recoil_x
	recoil_y = grip.recoil_y + stock.recoil_y
	
	print("recoil_x: " + String(recoil_x))
	print("recoil_y: " + String(recoil_y))
	print("ergo: " + String(ergo))
	print("auto: " + String(body.auto))
	print("projectile: " + String(body.projectile))
	print("damage: " + String(ammo.damage))
	print("shotSpeed: " + String(ammo.shotSpeed))
	var bodyModel = bodyMod.instance()
	$Body.add_child(bodyModel)
	var gripModel = gripMod.instance()
	$Grip.add_child(gripModel)
	var stockModel = stockMod.instance()
	$Stock.add_child(stockModel)
	

func shoot(aimcast):
	if(body.projectile):
		var bullet = am.instance()
		bullet.copy(ammo)
		get_node("Body/muzzle").add_child(bullet)
		bullet.apply_impulse(bullet.transform.basis.z, -bullet.transform.basis.z*bullet.shotSpeed)
	else:
		if aimcast.is_colliding():
			var target = aimcast.get_collider()
			var impact_pos = aimcast.get_collision_point()
		
			var bullet_impact = impact.instance()

#			get_node("/root/MainLevel").add_child(bullet_impact)
			target.add_child(bullet_impact)
		
#			bullet_impact.translation = impact_pos
			bullet_impact.global_transform = bullet_impact.transform.translated(impact_pos)
		
			if target.is_in_group("Enemy"):
				target.take_damage(ammo.damage)
