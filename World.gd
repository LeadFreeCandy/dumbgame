extends Spatial

const thread = false
const chunk_size = 32
const chunk_amount = 8
const num_threads = 1


var generator
var chunks = {}
var unready_chunks = {}
var current_chunk_pos

var threads = []
var sem
var mut

var erosion


func _ready():
#	randomize()
#	noise = OpenSimplexNoise.new()
#	noise.seed = randi()
#	noise.octaves = 9
#	noise.persistence = .45
#	noise.lacunarity = 2
#	noise.period = 160
	
	generator = MapGenerator.new()
	
	if thread:
		for i in range(num_threads):
			threads.append(Thread.new())
			threads[i].start(self, "_thread_function")
		
	sem = Semaphore.new()
	mut = Mutex.new()
	
#	erosion = ErosionNoise.new()
#	erosion = preload("res://world_assets/erosion.gdns").new()
	
#	print("0,0: ", erosion.get(1.0,1.0))
#	load_chunk([0,0])
	
func add_chunk(x, z):

#	print('called add chunk')
	var key = str(x) + "," + str(z)
	if chunks.has(key) or unready_chunks.has(key):
		return 
		
#	var key = str(x) + "," + str(z)
#	if chunks.has(key) or unready_chunks.has(key):
#		return 
	
	if not thread:
		load_chunk([x, z])

	if thread:
		if current_chunk_pos == null:
			current_chunk_pos = [x,z]

			sem.post()

		


func _thread_function():
	var gen = MapGenerator.new()
	
	while true:
		sem.wait()
		
#		mut.lock()
		var cur_pos = current_chunk_pos
		current_chunk_pos = null
#		mut.unlock()
		
		if cur_pos != null:
			var key = str(cur_pos[0]) + "," + str(cur_pos[1])
			mut.lock()
			unready_chunks[key] = 1
			mut.unlock()
		
			load_chunk(cur_pos)
			
#			mut.unlock()
#			

		
func load_chunk(arr):
	var x = arr[0]
	var z = arr[1]


	var chunk = Chunk.new(generator, x * chunk_size, z * chunk_size, chunk_size)
#	var chunk = Chunk.new(gen, x * chunk_size, z * chunk_size, chunk_size)

	chunk.translation = Vector3(x * chunk_size, 0, z * chunk_size)


	load_done(chunk)
	


#	call_deferred("load_done", chunk, thread)
	
	
func load_done(chunk):
	call_deferred("add_child", chunk)
#	add_child(chunk)
	var key = str(chunk.x/chunk_size) + "," + str(chunk.z/chunk_size)
#	var unready_key = str(chunk.x) + "," + str(chunk.z)

	
	
	mut.lock()

	chunks[key] = chunk

	unready_chunks.erase(key)
	mut.unlock()

#	thread.call_deferred('wait_to_finish')
#	thread.wait_to_finish()
	
func get_chunk(x,z):
	var key = str(x) + "," + str(z)
	if chunks.has(key):
		return chunks.get(key)
	return null
	
func _process(delta):
	update_chunks()
	clean_up_chunks()
	reset_chunks()
	
func update_chunks(): #todo set all chunks to should_remove dumbass
	var player_translation = get_node("/root/MainLevel/Player").translation
	var p_x = int(player_translation.x) / chunk_size
	var p_z = int(player_translation.z) / chunk_size
	
	for x in range(p_x - chunk_amount * 0.5, p_x + chunk_amount * .5):
		for z in range(p_z - chunk_amount * .5, p_z + chunk_amount * .5):
			add_chunk(x, z)
			var chunk = get_chunk(x, z)
			if chunk != null:
				chunk.should_remove = false
			

func clean_up_chunks():
	for key in chunks:
		var chunk = chunks[key]
		if chunk.should_remove:
			chunk.queue_free()
			chunks.erase(key)

func reset_chunks():
	for key in chunks:
		chunks[key].should_remove = true
