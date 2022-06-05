extends Spatial
class_name Tower


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var num_levels = 10
var tower_piece = preload("res://structures/TowerPiece.tscn")

var piece_height = 6.4

# Called when the node enters the scene tree for the first time.
func _ready():
	self.num_levels = num_levels
	
	for i in range(num_levels):
		var piece = tower_piece.instance()
		piece.translation = Vector3(0, piece_height * i, 0)
		piece.rotation = Vector3(0, deg2rad(180) * i, 0)
		add_child(piece)

#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
