extends StaticBody

onready var ammoScene = preload("res://GunParts/Ammo.tscn")

onready var sight = preload("res://GunParts/Sight.tscn")
onready var impact = preload("res://BulletImpact.tscn")

onready var body = $Body/Body
onready var grip = $Grip/Grip
onready var stock = $Stock/Stock

onready var bodyMod = $Body/Body/Model
onready var gripMod = $Grip/Grip/Model
onready var stockMod = $Stock/Stock/Model

var ammo

var hasSights = false

var recoil_x
var recoil_y
var ergo

var canShoot = true

func _ready():
	randomize()
	var r = randi()%100
	if r > 50:
		hasSights = true
	ammo = ammoStats.new(0)
	if hasSights:
		var sightModel = sight.instance()
		$Sight.add_child(sightModel)
	$Timer.set_wait_time(body.stats.rateOfFire/1000)

func shoot(aimcast):
	if canShoot:
		if(body.stats.projectile):
			var bullet = ammoScene.instance()
			bullet.get_child(1).material_override = ammo.material
			add_child(bullet)
			bullet.stats = ammo
			bullet.transform = $Body/muzzle.global_transform
			bullet.velocity = -bullet.transform.basis.z * ammo.shotSpeed
			
		else:
			if aimcast.is_colliding():
				var target = aimcast.get_collider()
				var impact_pos = aimcast.get_collision_point()
				
				var bullet_impact = impact.instance()
				bullet_impact.get_child(0).material_override = ammo.material
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

