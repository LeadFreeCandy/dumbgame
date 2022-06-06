extends Spatial
class_name Chunk

var mesh_instance
var noise
var x
var z
var chunk_size
var should_remove = true
var num_trees = 1000
var num_grass = 2000 /4000
var tree = preload("res://world_assets/grass_group.tres")
var grass = preload("res://world_assets/grass.tscn")
var rock = preload("res://world_assets/rock.tscn")

var rng = RandomNumberGenerator.new()


func _init(noise, x, z, chunk_size):
	self.noise = noise
	self.x = x
	self.z = z
	self.chunk_size = chunk_size
	rng.randomize()
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
		vertex.y = noise.get_noise_3d(vertex.x + x, vertex.y, vertex.z + z) * 80
		
		
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
	

#	rng.seed = hash("Godot")
	
	var tower = preload("res://structures/Tower.tscn")
	
	if rng.randf() < .1 and noise.get_noise_3d(x, 0, z) > 0:
		print(rng.randf())
		var t = tower.instance()
		t.translation = Vector3(0, noise.get_noise_3d(x, 0, z) * 80, 0)
		add_child(t)
#	var trees = get_node("Trees")
#	var trees = get_node("/root/")
#	print(trees)
#	var num_instances = trees.mualtimesh

	print("creating multi")
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.color_format = MultiMesh.COLOR_NONE
	multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_NONE
	multimesh.instance_count = num_trees
	multimesh.visible_instance_count = num_trees
	multimesh.mesh = tree
	

#	print("num trees")
#	print($Trees.multimesh.instance_count)
#	print("num trees 2")

	for i in range(num_trees):
#		print("modifying tree")
		var tree_x = rng.randf_range(-chunk_size/2, chunk_size/2)
		var tree_z = rng.randf_range(-chunk_size/2, chunk_size/2)
#		var tree_z = 0

		var tree_y = noise.get_noise_3d(tree_x + x, 0, tree_z + z) * 80

		if tree_y > 0:
			
			var dist = .25

			var dx = (tree_y - noise.get_noise_3d(tree_x + x + dist, 0, tree_z + z) * 80) / dist
			var dy = (tree_y - noise.get_noise_3d(tree_x + x, 0, tree_z + z + dist) * 80) / dist
			
			var slope = pow(dx, 2) + pow(dy, 2)
			
#			print(slope)
			
			if slope < .1:
	#			add_child(tree_inst)

				var pos = Transform.IDENTITY
				pos = pos.rotated(Vector3(0,0,1), deg2rad(-90))
				pos = pos.scaled(Vector3(.025,.05,.025))
				pos = pos.rotated(Vector3(0.0, 1, 0.0), rng.randf_range(0.0,10.0))
	#			pos = pos.translated(Vector3(tree_x, tree_y, tree_z))
				
				pos.origin = Vector3(tree_x, tree_y, tree_z)
	#			tree_inst.transform = Transform.IDENTITY.rotated(Vector3(0.0,1.0, 0.0), .01).translated(Vector3(tree_x, tree_y, tree_z))
				
	#			pos.translation = Vector3(tree_x, tree_y, tree_z)
				multimesh.set_instance_transform(i, pos)
				
				continue 
			
	
		var pos = Transform.IDENTITY
		
		pos = pos.translated(Vector3(0, -1000000, 0))
	

#			tree_inst.transform = Transform.IDENTITY.rotated(Vector3(0.0,1.0, 0.0), .01).translated(Vector3(tree_x, tree_y, tree_z))
#			pos.rotation = Vector3(0.0, rng.randf_range(0.0,10.0), 0.0)
#			pos.translation = Vector3(tree_x, tree_y, tree_z)
		multimesh.set_instance_transform(i, pos)

	var multi_inst = MultiMeshInstance.new()
	multi_inst.set_multimesh(multimesh)
	add_child(multi_inst)
#	print("created trees")
	
#	for i in range(num_grass):
#		var grass_x = rng.randf_range(-chunk_size/2, chunk_size/2)
#		var grass_z = rng.randf_range(-chunk_size/2, chunk_size/2)
##		var tree_z = 0
#
#		var grass_y = noise.get_noise_3d(grass_x + x, 0, grass_z + z) * 80
#
#		if grass_y > 0:
#
#			var grass_inst = grass.instance()
#			add_child(grass_inst)
#
#			grass_inst.global_transform = Transform.IDENTITY.translated(Vector3(grass_x, grass_y, grass_z))
#
#	for i in range(num_grass/2):
#		var grass_x = rng.randf_range(-chunk_size/2, chunk_size/2)
#		var grass_z = rng.randf_range(-chunk_size/2, chunk_size/2)
##		var tree_z = 0
#
#		var grass_y = noise.get_noise_3d(grass_x + x, 0, grass_z + z) * 80
#
#		if grass_y > 0:
#
#			var grass_inst = rock.instance()
#			add_child(grass_inst)
#
#			var pos = Transform.IDENTITY
#			pos = pos.translated(Vector3(grass_x, grass_y, grass_z))
#
##			tree_inst.transform = Transform.IDENTITY.rotated(Vector3(0.0,1.0, 0.0), .01).translated(Vector3(tree_x, tree_y, tree_z))
#			grass_inst.rotation = Vector3(0, rng.randf_range(0.0,10.0), rng.randf_range(0.0,10.0))
#			grass_inst.translation = Vector3(grass_x, grass_y, grass_z)
##			grass_inst.global_transform = Transform.IDENTITY.translated(Vector3(grass_x, grass_y, grass_z))
		
		
		
	
func generate_water():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
#	plane_mesh.subdivide_depth = chunk_size * .5 #this can be changed to change low poly effect
#	plane_mesh.subdivide_width = chunk_size * .5
	
	plane_mesh.material = preload("res://world_assets/water2.tres")
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = plane_mesh
	mesh_instance.create_trimesh_collision()
	
	mesh_instance.translate(Vector3(0, -2, 0))
	add_child(mesh_instance)
