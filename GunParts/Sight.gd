extends Spatial

func _ready():
	randomize()
	var material = SpatialMaterial.new()
	material.albedo_color = Color(randf(),randf(),randf())
	$Bottom.material_override = material
	$Top.material_override = material
	$Left.material_override = material
	$Right.material_override = material
