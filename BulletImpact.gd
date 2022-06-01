extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.start()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	queue_free() # Replace with function body.
#	pass
