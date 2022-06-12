use gdnative::api::{MeshInstance, PlaneMesh, SurfaceTool, MeshDataTool, Mesh, ArrayMesh};
use gdnative::prelude::*;
use std::time::{Duration, Instant};

mod erosion;
pub use erosion::*;

pub struct Chunk {
    pub erosion_map: ErosionMap,
    pub eroded: bool,
    pub mesh: Option<Ref<MeshInstance, Shared>>
}

impl Chunk {
    pub fn new(x: i32, y: i32) -> Self {

        let mut erosion_map = ErosionMap::new(x, y);

        Chunk {
            erosion_map,
            eroded: false,
            mesh: None
        }
    }

    pub fn erode(&mut self, north_map: &mut ErosionMap, east_map: &mut ErosionMap, south_map: &mut ErosionMap, west_map: &mut ErosionMap) {
        self.erosion_map.erode(north_map, east_map, south_map, west_map);
        self.eroded = true;
    }

    pub fn calc_mesh(&mut self) {
        // erosion_map.erode();

        // let mesh = MeshInstance::new();

        // let instant = Instant::now();

        let plane_mesh = PlaneMesh::new();
        plane_mesh.set_size(Vector2::new(TILE_SIZE as f32, TILE_SIZE as f32));
        
        plane_mesh.set_subdivide_depth(TILE_SIZE as i64 - 1);
        plane_mesh.set_subdivide_width(TILE_SIZE as i64 - 1);

        plane_mesh.set_center_offset(Vector3::new((TILE_SIZE/2) as f32, 0.0, (TILE_SIZE/2) as f32));
        // godot_print!("{:?}", plane_mesh.center_offset());

        let mut surface_tool = SurfaceTool::new();
        let data_tool = MeshDataTool::new();

        surface_tool.create_from(plane_mesh, 0);

        let array_plane = surface_tool.commit(ArrayMesh::new(), Mesh::ARRAY_COMPRESS_DEFAULT).unwrap();
        data_tool.create_from_surface(array_plane, 0);

        for i in 0..data_tool.get_vertex_count() {
            let mut vertex = data_tool.get_vertex(i);

            if vertex.x as usize >= 64{
                godot_print!("{:?}", vertex.x as usize);
            }
            if vertex.x as usize <= 0{
                godot_print!("{:?}", vertex.x as usize);
            }

            vertex.y = self.erosion_map.get_value(vertex.x as usize, vertex.z as usize) as f32 * 2.0;

            data_tool.set_vertex(i, vertex);
            
        }

        // godot_print!("{:?}", instant.elapsed());

        let array_plane = ArrayMesh::new().into_shared();

        data_tool.commit_to_surface(array_plane.clone());
        surface_tool.begin(Mesh::PRIMITIVE_TRIANGLES);
        surface_tool.create_from(array_plane, 0);
        surface_tool.generate_normals(false);

        let mesh_instance = MeshInstance::new();
        mesh_instance.set_mesh(surface_tool.commit(ArrayMesh::new(), Mesh::ARRAY_COMPRESS_DEFAULT).unwrap());
        mesh_instance.create_trimesh_collision();


        // mesh_instance.cast_shadow = true;
        let mesh = mesh_instance.into_shared();

        self.mesh = Some(mesh);
    }

    pub fn translate_mesh(&mut self, x: f32, y: f32) {
        unsafe{
            self.mesh.unwrap().assume_safe().translate(Vector3::new(x, 0.0, y));
        }
    }

    pub fn get_mesh(&self) -> Ref<MeshInstance, Shared> {
        self.mesh.unwrap()
    }


    // pub fn
}