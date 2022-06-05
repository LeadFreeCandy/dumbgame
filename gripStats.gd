extends Resource
class_name gripStats

var recoil_x : float
var recoil_y : float
var ergo : float

var recX : = [
	[25, 50],
	[10, 50],
	[0,40]
]

var recY : = [
	[25, 50],
	[10, 50],
	[0,50]
]

var ergoArr : = [
	[1, 10],
	[10, 25],
	[25,50]
]

func _init(type):
	recoil_x = rand_range(recX[type][0],recX[type][1])
	recoil_y = rand_range(recY[type][0],recY[type][1])
	ergo = rand_range(ergoArr[type][0],ergoArr[type][1]) 
	

