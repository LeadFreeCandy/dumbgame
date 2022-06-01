extends Spatial
class_name Chunk

var mesh_instance
var noise
var x
var z
var chunk_size
var should_remove = true
var num_trees = 250 / 16
var num_grass = 2000 / 16
var tree = preload("res://world_assets/tree.tscn")
var grass = preload("res://world_assets/grass.tscn")
var rock = preload("res://world_assets/rock.tscn")

func _init(noise, x, z, chunk_size):
	self.noise = noise
	self.x = x
	self.z = z
	self.chunk_size = chunk_size
	generate_chunk()
	generate_water()
	


# Called when the node enters the scene tree for the first time.

	
func generate_chunk():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.subdivide_depth = chunk_size * 1 #this can be changed to change low poly effect
	plane_mesh.subdivide_width = chunk_size * 1
	
	plane_mesh.material = preload("res://world_assets/terrain.tres")
	
	var surface_tool = SurfaceTool.new()
	var data_tool = MeshDataTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var array_plane = surface_tool.commit()
	var error = data_tool.create_from_surface(array_plane, 0)
	
#	var rng = RandomNumberGenerator.new()
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = noise.get_noise_3d(vertex.x + x, vertex.y, vertex.z + z) * 40
		
		
		data_tool.set_vertex(i, vertex)
	
	for s in range(array_plane.get_surface_count()):
		array_plane.surface_remove(s)
		
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	mesh_instance = MeshInstance.new()
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.create_trimesh_collision()
	mesh_instance.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF #todo check if correct
	add_child(mesh_instance)
	
	var rng = RandomNumberGenerator.new()
	rng.seed = hash("Godot")
	
	for i in range(num_trees):
		var tree_x = rng.randf_range(-chunk_size/2, chunk_size/2)
		var tree_z = rng.randf_range(-chunk_size/2, chunk_size/2)
#		var tree_z = 0
		
		var tree_y = noise.get_noise_3d(tree_x + x, 0, tree_z + z) * 40
		
		if tree_y > 0:
		
			var tree_inst = tree.instance()
			add_child(tree_inst)
			
			var pos = Transform.IDENTITY
			pos = pos.translated(Vector3(tree_x, tree_y, tree_z))
			
#			tree_inst.transform = Transform.IDENTITY.rotated(Vector3(0.0,1.0, 0.0), .01).translated(Vector3(tree_x, tree_y, tree_z))
			tree_inst.rotation = Vector3(0.0, rng.randf_range(0.0,10.0), 0.0)
			tree_inst.translation = Vector3(tree_x, tree_y, tree_z)
			
	for i in range(num_grass):
		var grass_x = rng.randf_range(-chunk_size/2, chunk_size/2)
		var grass_z = rng.randf_range(-chunk_size/2, chunk_size/2)
#		var tree_z = 0
		
		var grass_y = noise.get_noise_3d(grass_x + x, 0, grass_z + z) * 40
		
		if grass_y > 0:
		
			var grass_inst = grass.instance()
			add_child(grass_inst)
			
			grass_inst.global_transform = Transform.IDENTITY.translated(Vector3(grass_x, grass_y, grass_z))
			
	for i in range(num_grass/2):
		var grass_x = rng.randf_range(-chunk_size/2, chunk_size/2)
		var grass_z = rng.randf_range(-chunk_size/2, chunk_size/2)
#		var tree_z = 0
		
		var grass_y = noise.get_noise_3d(grass_x + x, 0, grass_z + z) * 40
		
		if grass_y > 0:
		
			var grass_inst = rock.instance()
			add_child(grass_inst)
			
			var pos = Transform.IDENTITY
			pos = pos.translated(Vector3(grass_x, grass_y, grass_z))
			
#			tree_inst.transform = Transform.IDENTITY.rotated(Vector3(0.0,1.0, 0.0), .01).translated(Vector3(tree_x, tree_y, tree_z))
			grass_inst.rotation = Vector3(0, rng.randf_range(0.0,10.0), rng.randf_range(0.0,10.0))
			grass_inst.translation = Vector3(grass_x, grass_y, grass_z)
#			grass_inst.global_transform = Transform.IDENTITY.translated(Vector3(grass_x, grass_y, grass_z))
		
		
		
	
func generate_water():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
#	plane_mesh.subdivide_depth = chunk_size * .5 #this can be changed to change low poly effect
#	plane_mesh.subdivide_width = chunk_size * .5
	
	plane_mesh.material = preload("res://world_assets/water.tres")
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = plane_mesh
	add_child(mesh_instance)
