extends Spatial

const chunk_size = 64
const chunk_amount = 16
const num_threads = 16


var noise
var chunks = {}
var unready_chunks = {}
var current_chunk_pos

var threads = []
var sem
var mut


func _ready():
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 9
	noise.persistence = .45
	noise.lacunarity = 2
	noise.period = 160
	
	
	for i in range(num_threads):
		threads.append(Thread.new())
		threads[i].start(self, "_thread_function")
	
	sem = Semaphore.new()
	mut = Mutex.new()
	
func add_chunk(x, z):

#	print('called add chunk')
	var key = str(x) + "," + str(z)
	if chunks.has(key) or unready_chunks.has(key):
		return 
		
#	var key = str(x) + "," + str(z)
#	if chunks.has(key) or unready_chunks.has(key):
#		return 
	
#	load_chunk([x, z])
#	print("waiting for lock")
#	mut.lock()
#	print("done waiting")
	if current_chunk_pos == null:
		
		print("adding current chunk")
		current_chunk_pos = [x,z]
		
		sem.post()

		
#	mut.unlock()
	
		
		
	
	
#	load_chunk([thread, x, z])
#	if first_thread:
#		print("should happen once")
#		thread.start(self, "load_chunk", [thread, x, z], 2)
#		unready_chunks[key] = 1
#		first_thread = false
#
#	elif not thread.is_alive():
##		thread = Thread.new()
##		thread.wait_to_finish()
##		if thread.is_active():
##			print("this should happen once")
##			thread.wait_to_finish()
##		thread = Thread.new()
#		print("starting thread")
#		thread.start(self, "load_chunk", [thread, x, z])
#		print("started")
#		unready_chunks[key] = 1
#		print("set_unready")



#	elif not thread.is_active():
#		print("starting thread")
#		thread.start(self, "load_chunk", [thread, x, z])
#		print("started")
#		unready_chunks[key] = 1
#		print("set_unready")
#	else:
#		pass
#		print("waiting")
#	load_chunk([thread, x, z])

func _thread_function():
	while true:
		sem.wait()
		
#		mut.lock()
		var cur_pos = current_chunk_pos
		current_chunk_pos = null
#		mut.unlock()
		
		if cur_pos != null:
			print("starting on chunk")
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

	print("creating chunk with x and z", x, z)
	var chunk = Chunk.new(noise, x * chunk_size, z * chunk_size, chunk_size)
	print("created 1")
	chunk.translation = Vector3(x * chunk_size, 0, z * chunk_size)

	print("created")
	load_done(chunk)
	
#	thread.call_deferred('wait_to_finish')
	print("finished")

#	call_deferred("load_done", chunk, thread)
	
	
func load_done(chunk):
	call_deferred("add_child", chunk)
#	add_child(chunk)
	var key = str(chunk.x/chunk_size) + "," + str(chunk.z/chunk_size)
#	var unready_key = str(chunk.x) + "," + str(chunk.z)
	print("attempting to lock")
	
	
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
