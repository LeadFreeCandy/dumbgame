use gdnative::prelude::*;
use std::collections::HashMap;
use std::time::{Duration, Instant};
use std::cell::{RefCell, RefMut};

#[cfg(test)]
mod tests;

mod chunk;
use chunk::*;

// Function that registers all exposed classes to Godot
fn init(handle: InitHandle) {
    handle.add_class::<TiledErosionNoise>();
}

// Macro that creates the entry-points of the dynamic library.
godot_init!(init);

#[derive(NativeClass)]
#[inherit(Node)]
pub struct TiledErosionNoise{
    maps: HashMap<(i32, i32), RefCell<Chunk>>,
    // tile_size: usize,
    // erosion_iters: u32,
    // scale: f64,
    // seed: u32
}

#[methods]
impl TiledErosionNoise{
    fn new(_owner: &Node) -> Self {
        TiledErosionNoise{
            maps: HashMap::new(), 
            // tile_size: 0,
            // erosion_iters: 0,
            // scale: 0.0,
            // seed: 42
        }
    }

    #[export]
    fn _ready(&mut self, owner: &Node) {
        godot_print!("Hello from Rust!");

        let node = owner.get_node("../Player");

        unsafe {

        godot_print!("{:?}", node.unwrap().assume_safe().name());

        }


        let instant = Instant::now();

        let mut center_chunk = Chunk::new(0, 0);
        let mut north_chunk = Chunk::new(0, 1);
        let mut east_chunk = Chunk::new(1, 0);
        let mut south_chunk = Chunk::new(0, -1);
        let mut west_chunk = Chunk::new(-1, 0);

        center_chunk.erode(&mut north_chunk.erosion_map, &mut east_chunk.erosion_map, &mut south_chunk.erosion_map, &mut west_chunk.erosion_map);
        // north_chunk.erode()
        
        godot_print!("{:?}", instant.elapsed());

        center_chunk.calc_mesh();
        north_chunk.calc_mesh();
        east_chunk.calc_mesh();
        south_chunk.calc_mesh();
        west_chunk.calc_mesh();

        unsafe {
            north_chunk.mesh.unwrap().assume_safe().translate(Vector3::new(0.0, 0.0, 64 as f32));
        }
        unsafe {
            east_chunk.mesh.unwrap().assume_safe().translate(Vector3::new(64 as f32, 0.0, 0.0));
        }
        unsafe {
            south_chunk.mesh.unwrap().assume_safe().translate(Vector3::new(0.0, 0.0, -64 as f32));
        }
        unsafe {
            west_chunk.mesh.unwrap().assume_safe().translate(Vector3::new(-64 as f32, 0.0, 0.0));
        }
        
        owner.add_child(center_chunk.get_mesh(), true);
        owner.add_child(north_chunk.get_mesh(), true);
        owner.add_child(east_chunk.get_mesh(), true);
        owner.add_child(south_chunk.get_mesh(), true);
        owner.add_child(west_chunk.get_mesh(), true);

        
    }

    fn create(&mut self, x: i32, y: i32) -> &RefCell<Chunk>{
        if !self.maps.contains_key(&(x, y)){
            self.maps.insert((x,y), RefCell::new(Chunk::new(x, y)));
        }
        return self.maps.get_mut(&(x, y)).unwrap();
    }

    fn erode(&mut self, x: i32, y: i32) -> RefMut<Chunk>{

        

        self.create(x, y + 1);
        self.create(x + 1, y);
        self.create(x, y - 1);
        self.create(x - 1, y);
        self.create(x, y);

        

        let mut north = self.maps.get(&(x, y + 1)).unwrap().borrow_mut();
        let mut east = self.maps.get(&(x + 1, y)).unwrap().borrow_mut();
        let mut south = self.maps.get(&(x, y - 1)).unwrap().borrow_mut();
        let mut west = self.maps.get(&(x - 1, y)).unwrap().borrow_mut();
        let mut center = self.maps.get(&(x, y)).unwrap().borrow_mut();

        if center.eroded{
            return center;
        }

        center.erode(&mut north.erosion_map, &mut east.erosion_map, &mut south.erosion_map, &mut west.erosion_map);

        return center
    }

    fn create_and_display(&mut self, x: i32, y:i32){
        self.erode(x, y);
        self.erode(x, y+1);
        self.erode(x, y-1);
        self.erode(x+1, y);
        self.erode(x-1, y);

        let mut center = self.maps.get(&(x, y)).unwrap().borrow_mut();

        center.calc_mesh();

        center.translate_mesh((TILE_SIZE as i32 * x) as f32, (TILE_SIZE as i32 * y) as f32)

        // let east = self.maps.get_mut(&(x + 1, y)).unwrap();
        // let south = self.maps.get_mut(&(x, y - 1)).unwrap();
        // let west = self.maps.get_mut(&(x - 1, y)).unwrap();
        // let center = self.maps.get_mut(&(x, y)).unwrap();
        // let mut center_chunk = self.create(x, y);

        // center.erode(&mut north.erosion_map, &mut east.erosion_map, &mut south.erosion_map, &mut west.erosion_map);


    }

    fn add_chunk(x: i32, y:i32){

    }
    // #[export]
    // fn setup(&mut self, _owner: &Node, tile_size: usize, erosion_iters: u32, scale: f64, seed: u32) {

    //     self.tile_size = tile_size;
    //     self.erosion_iters = erosion_iters;
    //     self.scale = scale; 
    //     self.seed = seed;
    // }

    // #[export]
    // fn get(&mut self, _owner: &Node, x: usize, z: usize) -> f64{

    //     let map_cords = (x / self.tile_size, z / self.tile_size); 
    //     let map_pos = (x % self.tile_size, z % self.tile_size);


    //     if self.maps.get(&map_cords).is_none(){
    //         let corner = (map_cords.0 as f64 * self.scale, map_cords.1 as f64 * self.scale);



    //         let mut map = ErosionMap::new(corner.0, corner.0 + self.scale, corner.1, corner.1 + self.scale, self.tile_size, self.tile_size);

    //         map.save_to_file("start");
    //         map.erode(self.erosion_iters);
    //         map.save_to_file("end");

    //         self.maps.insert(map_cords, map);

    //     }

    //     return self.maps.get(&map_cords).unwrap().get_value(map_pos.0, map_pos.1)
    // }
}




