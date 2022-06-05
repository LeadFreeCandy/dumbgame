extends StaticBody

onready var bodyMod = preload("res://Body.tscn")
onready var gripMod = preload("res://Grip.tscn")
onready var stockMod = preload("res://Stock.tscn")
onready var impact = preload("res://BulletImpact.tscn")
onready var am = preload("res://Ammo.tscn")
onready var sight = preload("res://Sight.tscn")

var body
var grip
var stock
var ammo
var hasSights = false

var recoil_x
var recoil_y
var ergo

var canShoot = true

func _ready():
	print("ready")
	randomize()
	var r = randi()%100
	if r > 50:
		hasSights = true
	body = Body.new(0)
	grip = Grip.new(0)
	stock = Stock.new(0)
	ammo = Ammo.new(0)
	
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
	print("rateOfFire: " + String(body.rateOfFire))
	
	var bodyModel = bodyMod.instance()
	$Body.add_child(bodyModel)
	var gripModel = gripMod.instance()
	$Grip.add_child(gripModel)
	var stockModel = stockMod.instance()
	$Stock.add_child(stockModel)
	if hasSights:
		var sightModel = sight.instance()
		$Sight.add_child(sightModel)
	$Timer.set_wait_time(body.rateOfFire/1000)
	

func shoot(aimcast):
	if canShoot:
		if(body.projectile):
			var bullet = am.instance()
			bullet.copy(ammo)
			add_child(bullet)
			bullet.transform = $Body/muzzle.global_transform
			bullet.velocity = -bullet.transform.basis.z * bullet.shotSpeed
			
		else:
			if aimcast.is_colliding():
				var target = aimcast.get_collider()
				var impact_pos = aimcast.get_collision_point()
			
				var bullet_impact = impact.instance()

#				get_node("/root/MainLevel").add_child(bullet_impact)
				target.add_child(bullet_impact)
			
#				bullet_impact.translation = impact_pos
				bullet_impact.global_transform = bullet_impact.transform.translated(impact_pos)
			
				if target.is_in_group("Enemy"):
					target.health -= ammo.damage
		canShoot = false
		$Timer.start()


func _on_Timer_timeout():
	canShoot = true
