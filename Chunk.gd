extends Spatial
class_name Chunk

var mesh_instance
var noise
var x
var z
var chunk_size
var should_remove = true
var num_trees = 5
var num_small_trees = 20
var num_grass = 1000
var grass = preload("res://world_assets/grass_group.tres")
var tree = preload("res://world_assets/bigtree_mesh.tres")
var small_tree = preload("res://world_assets/tree_mesh.tres")
#var rock = preload("res://world_assets/rock.tscn")

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

func generate_multi_inst(mesh, quantity, slope_thresh, rotation = [Vector3(0,0,1), 0], scale = Vector3(1,1,1), random_rot = true, offset = Vector3(0,0,0)):
	
	print("creating multi")
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.color_format = MultiMesh.COLOR_NONE
	multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_NONE
	multimesh.instance_count = quantity
	multimesh.visible_instance_count = quantity
	multimesh.mesh = mesh
	

#	print("num trees")
#	print($Trees.multimesh.instance_count)
#	print("num trees 2")

	for i in range(quantity):
#		print("modifying tree")
		var obj_x = rng.randf_range(-chunk_size/2, chunk_size/2)
		var obj_z = rng.randf_range(-chunk_size/2, chunk_size/2)
#		var tree_z = 0

		var obj_y = noise.get_noise_3d(obj_x + x, 0, obj_z + z) * 80

		if obj_y > 0:
			
			var dist = .25

			var dx = (obj_y - noise.get_noise_3d(obj_x + x + dist, 0, obj_z + z) * 80) / dist
			var dy = (obj_y - noise.get_noise_3d(obj_x + x, 0, obj_z + z + dist) * 80) / dist
			
			var slope = pow(dx, 2) + pow(dy, 2)
			
#			print(slope)
			
			if slope < slope_thresh:
	#			add_child(tree_inst)

				var pos = Transform.IDENTITY
				pos = pos.rotated(rotation[0], rotation[1])
				pos = pos.scaled(scale)
				
				if random_rot:
					pos = pos.rotated(Vector3(0.0, 1, 0.0), rng.randf_range(0.0,10.0))
	#			pos = pos.translated(Vector3(tree_x, tree_y, tree_z))
				
				pos.origin = Vector3(obj_x, obj_y, obj_z) + offset
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

#	print("creating multi")
#	var multimesh = MultiMesh.new()
#	multimesh.transform_format = MultiMesh.TRANSFORM_3D
#	multimesh.color_format = MultiMesh.COLOR_NONE
#	multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_NONE
#	multimesh.instance_count = num_grass
#	multimesh.visible_instance_count = num_grass
#	multimesh.mesh = grass
	
	generate_multi_inst(tree, num_trees, .5, [Vector3(0,0,1), 0], Vector3(.5, .5, .5), true, Vector3(0, 15, 0))
	generate_multi_inst(grass, num_grass, .1, [Vector3(0,0,1), deg2rad(-90)], Vector3(.025, .05, .025), true)
	generate_multi_inst(small_tree, num_small_trees, .2, [Vector3(0,0,1), 0], Vector3(4, 4, 4), true, Vector3(0, 2, 0))

#	print("num trees")
#	print($Trees.multimesh.instance_count)
#	print("num trees 2")

#	for i in range(num_grass):
##		print("modifying tree")
#		var obj_x = rng.randf_range(-chunk_size/2, chunk_size/2)
#		var obj_z = rng.randf_range(-chunk_size/2, chunk_size/2)
##		var tree_z = 0
#
#		var obj_y = noise.get_noise_3d(obj_x + x, 0, obj_z + z) * 80
#
#		if obj_y > 0:
#
#			var dist = .25
#
#			var dx = (obj_y - noise.get_noise_3d(obj_x + x + dist, 0, obj_z + z) * 80) / dist
#			var dy = (obj_y - noise.get_noise_3d(obj_x + x, 0, obj_z + z + dist) * 80) / dist
#
#			var slope = pow(dx, 2) + pow(dy, 2)
#
##			print(slope)
#
#			if slope < .1:
#	#			add_child(tree_inst)
#
#				var pos = Transform.IDENTITY
#				pos = pos.rotated(Vector3(0,0,1), deg2rad(-90))
#				pos = pos.scaled(Vector3(.025,.05,.025))
#				pos = pos.rotated(Vector3(0.0, 1, 0.0), rng.randf_range(0.0,10.0))
#	#			pos = pos.translated(Vector3(tree_x, tree_y, tree_z))
#
#				pos.origin = Vector3(obj_x, obj_y, obj_z)
#	#			tree_inst.transform = Transform.IDENTITY.rotated(Vector3(0.0,1.0, 0.0), .01).translated(Vector3(tree_x, tree_y, tree_z))
#
#	#			pos.translation = Vector3(tree_x, tree_y, tree_z)
#				multimesh.set_instance_transform(i, pos)
#
#				continue 
#
#
#		var pos = Transform.IDENTITY
#
#		pos = pos.translated(Vector3(0, -1000000, 0))
#
#
##			tree_inst.transform = Transform.IDENTITY.rotated(Vector3(0.0,1.0, 0.0), .01).translated(Vector3(tree_x, tree_y, tree_z))
##			pos.rotation = Vector3(0.0, rng.randf_range(0.0,10.0), 0.0)
##			pos.translation = Vector3(tree_x, tree_y, tree_z)
#		multimesh.set_instance_transform(i, pos)
#
#	var multi_inst = MultiMeshInstance.new()
#	multi_inst.set_multimesh(multimesh)
#	add_child(multi_inst)
#
#	var multimesh2 = MultiMesh.new()
#	multimesh2.transform_format = MultiMesh.TRANSFORM_3D
#	multimesh2.color_format = MultiMesh.COLOR_NONE
#	multimesh2.custom_data_format = MultiMesh.CUSTOM_DATA_NONE
#	multimesh2.instance_count = num_trees
#	multimesh2.visible_instance_count = num_trees
#	multimesh2.mesh = tree
#
#	for i in range(num_trees):
##		print("modifying tree")
#		var obj_x = rng.randf_range(-chunk_size/2, chunk_size/2)
#		var obj_z = rng.randf_range(-chunk_size/2, chunk_size/2)
##		var tree_z = 0
#
#		var obj_y = noise.get_noise_3d(obj_x + x, 0, obj_z + z) * 80
#
#		if obj_y > 0:
#
#			var dist = .25
#
#			var dx = (obj_y - noise.get_noise_3d(obj_x + x + dist, 0, obj_z + z) * 80) / dist
#			var dy = (obj_y - noise.get_noise_3d(obj_x + x, 0, obj_z + z + dist) * 80) / dist
#
#			var slope = pow(dx, 2) + pow(dy, 2)
#
##			print(slope)
#
#			if slope < .5:
#	#			add_child(tree_inst)
#
#				var pos = Transform.IDENTITY
##				pos = pos.rotated(Vector3(0,0,1), deg2rad(-90))
#				pos = pos.scaled(Vector3(.5,.5,.5))
#				pos = pos.rotated(Vector3(0.0, 1, 0.0), rng.randf_range(0.0,10.0))
#	#			pos = pos.translated(Vector3(tree_x, tree_y, tree_z))
#
#				pos.origin = Vector3(obj_x, obj_y+15, obj_z)
#	#			tree_inst.transform = Transform.IDENTITY.rotated(Vector3(0.0,1.0, 0.0), .01).translated(Vector3(tree_x, tree_y, tree_z))
#
#	#			pos.translation = Vector3(tree_x, tree_y, tree_z)
#				multimesh2.set_instance_transform(i, pos)
#
#				continue 
#
#
#		var pos = Transform.IDENTITY
#
#		pos = pos.translated(Vector3(-10000, -10000, -10000))
#
#
##			tree_inst.transform = Transform.IDENTITY.rotated(Vector3(0.0,1.0, 0.0), .01).translated(Vector3(tree_x, tree_y, tree_z))
##			pos.rotation = Vector3(0.0, rng.randf_range(0.0,10.0), 0.0)
##			pos.translation = Vector3(tree_x, tree_y, tree_z)
#		multimesh2.set_instance_transform(i, pos)
#
#	var multi_inst2 = MultiMeshInstance.new()
#	multi_inst2.set_multimesh(multimesh2)
#	add_child(multi_inst2)
#
#

		
	
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
