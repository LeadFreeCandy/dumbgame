extends MeshInstance


func _ready():
	randomize()
	
	var material = SpatialMaterial.new()
	material.albedo_color = Color(randf(),randf(),randf())
	self.material_override = material



