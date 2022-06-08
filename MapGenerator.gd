extends Node
class_name MapGenerator

const biome_sharpness = 3
const biome_size_factor = 12

var height_noise
var height_multiplier
var humidity_noise
var temp_noise

var erosion

#[Humidy, Temp]
var biomes = {"desert": [-.6,.6], "rainforest": [.6,.6], "grass": [0,0], "snow": [0, -.6]}
var colors = {"desert": Color(1, .5, 0), "rainforest": Color(0, 1, 0), "grass": Color(.5, 1, .5), "snow": Color(1, 1, 1)}

#var biomes = {"forest": [1,1], "snow": [-1, -1]}
#var colors = {"forest" : Color(.1, .7, .1), "snow": Color(1, 1, 1)}

func _init():
	
	randomize()
	
	height_multiplier = 80 * 2
	
#	height_noise = OpenSimplexNoise.new()
#	height_noise.seed = randi()
#	height_noise.octaves = 9
#	height_noise.persistence = .45
#	height_noise.lacunarity = 2
#	height_noise.period = 160 * 4

	erosion = preload("res://world_assets/erosion.gdns").new()
	
	erosion.setup(512, 200_000, 5.0, 0)
#	erosion.erode(200000)
	
	humidity_noise = OpenSimplexNoise.new()
	humidity_noise.seed = randi()
	humidity_noise.octaves = 1
	humidity_noise.period = 160 * biome_size_factor
	
	temp_noise = OpenSimplexNoise.new()
	temp_noise.seed = randi()
	temp_noise.octaves = 1
	temp_noise.period = 160 * biome_size_factor
	
	print(get_biomes(0.1,0))
	
	


func get_height_raw(x, z):
	return height_noise.get_noise_2d(x, z) * height_multiplier
	
func get_height(x, z):
#	print(x, z)
#	var percents = get_biomes_at_pos(x, z)
#	var raw_height = get_height_raw(x, z)
#	var height = 0
#
#	height += (raw_height/3 + 20 ) * percents.desert
#	height += (raw_height/1.5) * percents.grass
#	height += raw_height * percents.rainforest
#	height += (raw_height + 60) * percents.snow

	return erosion.get(int(x*4), int(z*4)) * 10
	
#	return height
	
	
func get_color(x, z):
	var percents = get_biomes_at_pos(x, z)
	
	var color = Color(0,0,0)
	
	for key in percents.keys():
		color += colors[key] * percents[key]
	
	return color
	
#	if percents["forest"] > .5:
#		return colors["forest"]
#	else:
#		return colors["snow"]
	

func dist_squared(a, b):
	return pow(pow(a[0] - b[0], 2) + pow(a[1] - b[1], 2), -biome_sharpness)

func get_biomes_at_pos(x, z):
	var humidity = get_humidity(x, z)
	var temp = get_temp(x, z)
	
	return get_biomes(humidity, temp)

func get_biomes(humidity, temp):
	var biome_percents = {}
	
	for key in biomes.keys():
		biome_percents[key] = dist_squared([humidity, temp], biomes[key])
		
	var sum = 0
	
	for val in biome_percents.values():
		sum += val
		
	for key in biome_percents.keys():
		biome_percents[key] /= sum
		
	return biome_percents

func get_humidity(x, z):
	return humidity_noise.get_noise_2d(x, z)
	
func get_temp(x, z):
	return temp_noise.get_noise_2d(x, z)
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
