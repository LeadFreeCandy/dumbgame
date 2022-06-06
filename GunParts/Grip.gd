extends Spatial

var stats : Resource


func _ready():
	stats = gripStats.new(0)
	stats.material = $Model.material_override
