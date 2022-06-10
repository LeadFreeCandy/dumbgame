use noise::{Fbm, utils::PlaneMapBuilder, utils::NoiseMapBuilder, MultiFractal, BasicMulti, HybridMulti};
use rand::prelude::*;
use gdnative::prelude::*;
use std::collections::HashMap;

#[cfg(test)]
mod tests;

// Function that registers all exposed classes to Godot
fn init(handle: InitHandle) {
    handle.add_class::<TiledErosionNoise>();
}

// Macro that creates the entry-points of the dynamic library.
godot_init!(init);

const EROSION_RADIUS: u32 = 2; //2-8
const INERTIA: f64 = 0.1; // 0-1
const SEDIMENT_CAPACITY_FACTOR: f64 = 4.0;
const MIN_SEDIMENT_CAPACITY: f64 = 0.01;
const ERODE_SPEED: f64 = 0.3; //0-1
const DEPOSIT_SPEED: f64 = 0.3; //0-1
const EVAPORATION_SPEED: f64 = 0.01; //0-1
const GRAVITY: f64 = 4.0; //0-1
const MAX_DROPLET_LIFETIME: u32 = 30;

const INITIAL_WATER_VOLUME: f64 = 1.0;
const INITIAL_SPEED: f64 = 1.0;

type WeightArray = [[f64; EROSION_RADIUS as usize * 2 - 1]; EROSION_RADIUS as usize * 2 - 1];

#[derive(NativeClass)]
#[inherit(Node)]
pub struct TiledErosionNoise{
    maps: HashMap<(usize, usize), ErosionMap>,
    tile_size: usize,
    erosion_iters: u32,
    scale: f64,
    seed: u32
}

#[methods]
impl TiledErosionNoise{
    fn new(_owner: &Node) -> Self {
        TiledErosionNoise{
            maps: HashMap::new(), 
            tile_size: 0,
            erosion_iters: 0,
            scale: 0.0,
            seed: 42
        }
    }

    #[export]
    fn setup(&mut self, _owner: &Node, tile_size: usize, erosion_iters: u32, scale: f64, seed: u32) {

        self.tile_size = tile_size;
        self.erosion_iters = erosion_iters;
        self.scale = scale; 
        self.seed = seed;
    }

    #[export]
    fn get(&mut self, _owner: &Node, x: usize, z: usize) -> f64{

        let map_cords = (x / self.tile_size, z / self.tile_size); 
        let map_pos = (x % self.tile_size, z % self.tile_size);


        if self.maps.get(&map_cords).is_none(){
            let corner = (map_cords.0 as f64 * self.scale, map_cords.1 as f64 * self.scale);



            let mut map = ErosionMap::new(corner.0, corner.0 + self.scale, corner.1, corner.1 + self.scale, self.tile_size, self.tile_size);

            map.save_to_file("start");
            map.erode(self.erosion_iters);
            map.save_to_file("end");

            self.maps.insert(map_cords, map);

        }

        return self.maps.get(&map_cords).unwrap().get_value(map_pos.0, map_pos.1)
    }
}



// #[derive(NativeClass)]
// #[inherit(Node)]
// pub struct ErosionNoise{
//     map : ErosionMap,
// }


// impl ErosionNoise {
//     // Constructor, either:
//     fn new(_owner: &Node) -> Self {
//         let map = ErosionMap::new(1, 1, 5.0);

//         ErosionNoise{
//             map,
//         }

//     }


//     fn create_map(&mut self, _owner: &Node, width: usize, height: usize, scale: f64) {
//         self.map = ErosionMap::new(width, height, scale);
//         self.map.save_to_file("start_image.png");
//     }


//     fn erode(&mut self, _owwner: &Node, iterations: u32) {
//         self.map.erode(iterations);
//         self.map.save_to_file("end_image.png");
//     }


//     fn get(&self, _owner: &Node, x: f64, y: f64) -> f64 {

//         //check if in bounds
//         if x < 0.0 || x > self.map.noise_map.size().0 as f64 || y < 0.0 || y > self.map.noise_map.size().1 as f64 {
//             return 0.0;
//         }

//         self.map.get_value(x as usize, y as usize)
//     }

// }

struct Droplet {
    pos : [f64; 2],
    dir : [f64; 2],
    speed : f64,
    water : f64,
    sediment : f64
}
impl Droplet {
    fn new(pos: [f64; 2]) -> Self {
        Self {
            pos,
            dir: [0.0,0.0],
            speed: INITIAL_SPEED,
            water :INITIAL_WATER_VOLUME,
            sediment: 0.0
        }
    }
}


pub struct ErosionMap {
    noise_map: noise::utils::NoiseMap
}

impl ErosionMap {
    pub fn new(start_x: f64, end_x: f64, start_y: f64, end_y: f64, width: usize, height: usize) -> ErosionMap {
        // let noise_module = Fbm::new();
        let noise_module = Fbm::new()
                                .set_octaves(10)
                                .set_persistence(0.6)
                                .set_lacunarity(2.0);



        let noise_map = 
            PlaneMapBuilder::new(&noise_module)
            .set_size(width, height)
            .set_x_bounds(start_x, end_x)
            .set_y_bounds(start_y, end_y)
            .build();

        ErosionMap {
            noise_map
        }
    }

    pub fn erode(&mut self, num_iters: u32) {


        let mut weights: WeightArray = [[0.0; EROSION_RADIUS as usize * 2 - 1]; EROSION_RADIUS as usize * 2 - 1];
        for y in 0..(EROSION_RADIUS * 2 + 1) as usize{
            for x in 0..(EROSION_RADIUS * 2 + 1) as usize{
                

                let dist = (x as f64 - EROSION_RADIUS as f64).powi(2) + (y as f64 - EROSION_RADIUS as f64).powi(2);
                if dist < EROSION_RADIUS as f64 * EROSION_RADIUS as f64{
                    weights[y-1][x-1] = 1.0 - dist.sqrt() / (EROSION_RADIUS as f64);    
                }
                
            }
        }

        let weight_sum = weights.iter().map(|row| row.iter().sum::<f64>()).sum::<f64>();
        for y in 0..weights.len(){
            for x in 0..weights[0].len(){
                weights[y][x] /= weight_sum;
            }
        }


        println!("{:?}", weights);

        let mut rng = StdRng::seed_from_u64(42);

        for _ in 0..num_iters {
            let size = self.noise_map.size(); //todo fix horrible range impl
            let mut droplet = Droplet::new([((rng.gen_range(0.0..1.0) * (size.0 - 1) as f64) as usize) as f64, ((rng.gen_range(0.0..1.0) * (size.0 - 1) as f64) as usize) as f64]);

            for _ in 0..MAX_DROPLET_LIFETIME {
                let node = [droplet.pos[0] as usize, droplet.pos[1] as usize];
                let cell_offset = [droplet.pos[0] - node[0] as f64, droplet.pos[1] - node[1] as f64];

                let grad = calc_height_gradient(&self.noise_map, &droplet);

                droplet.dir[0] = droplet.dir[0] * INERTIA - grad.gradient[0] * (1.0 - INERTIA);   
                droplet.dir[1] = droplet.dir[1] * INERTIA - grad.gradient[1] * (1.0 - INERTIA);

                let len = (droplet.dir[0] * droplet.dir[0] + droplet.dir[1] * droplet.dir[1]).sqrt();

                droplet.dir[0] = droplet.dir[0] / len;
                droplet.dir[1] = droplet.dir[1] / len;

                droplet.pos[0] += droplet.dir[0];
                droplet.pos[1] += droplet.dir[1];

                //stop if not moving or left map //todo check if drop stop moving 
                if len < 0.001 || droplet.pos[0] < 0.0 || droplet.pos[1] < 0.0 || droplet.pos[0] + 1.0 >= size.0 as f64 || droplet.pos[1] + 1.0 >= size.1 as f64 {
                    break;
                }

                let new_height = calc_height_gradient(&self.noise_map, &droplet).height;
                let delta_height = new_height - grad.height;

                let sediment_capacity = (-delta_height * droplet.speed * droplet.water * SEDIMENT_CAPACITY_FACTOR).max(MIN_SEDIMENT_CAPACITY);

                if droplet.sediment > sediment_capacity || delta_height > 0.0 {
                    let amount_to_deposit = if delta_height > 0.0 {
                        (droplet.sediment).min(delta_height)
                    } else {
                        (droplet.sediment - sediment_capacity) * DEPOSIT_SPEED
                    };
                    droplet.sediment -= amount_to_deposit;

                    self.add_value(node[0], node[1], amount_to_deposit * (1.0 - cell_offset[0]) * (1.0 - cell_offset[1]));
                    self.add_value(node[0] + 1, node[1], amount_to_deposit * cell_offset[0] * (1.0 - cell_offset[1]));
                    self.add_value(node[0], node[1] + 1, amount_to_deposit * (1.0 - cell_offset[0]) * cell_offset[1]);
                    self.add_value(node[0] + 1, node[1] + 1, amount_to_deposit * cell_offset[0] * cell_offset[1]);
                } else {
                    let amount_to_erode = ((sediment_capacity - droplet.sediment) * ERODE_SPEED).min(-delta_height);


                    self.apply_weighted_brush(node, weights, amount_to_erode);
                }

                droplet.speed = (droplet.speed * droplet.speed + delta_height * GRAVITY).sqrt();
                droplet.water *= 1.0 - EVAPORATION_SPEED;

            }

            
        }

        fn calc_height_gradient(noise_map: &noise::utils::NoiseMap, droplet: &Droplet) -> HeightGradient {
            let node = [droplet.pos[0] as usize, droplet.pos[1] as usize];
            let cell_offset = [droplet.pos[0] - node[0] as f64, droplet.pos[1] - node[1] as f64];

            let heightNW = noise_map.get_value(node[0], node[1]);
            let heightNE = noise_map.get_value(node[0] + 1, node[1]);
            let heightSW = noise_map.get_value(node[0], node[1] + 1);
            let heightSE = noise_map.get_value(node[0] + 1, node[1] + 1);

            let x = cell_offset[0];
            let y = cell_offset[1];

            let gradientX = (heightNE - heightNW) * (1.0 - y) + (heightSE - heightSW) * y;
            let gradientY = (heightSW - heightNW) * (1.0 - x) + (heightSE - heightNE) * x;

            let height = heightNW * (1.0 - x) * (1.0 - y) + heightNE * x * (1.0 - y) + heightSW * (1.0 - x) * y + heightSE * x * y;

            return HeightGradient {
                height,
                gradient: [gradientX, gradientY]
            };
        }

    }

    fn get_value(&self, x: usize, y: usize) -> f64 {
        self.noise_map.get_value(x, y)
    }

    fn add_value(&mut self, x: usize, y: usize, value: f64) {
        self.noise_map.set_value(x, y, self.get_value(x, y) + value);
    }

    fn apply_weighted_brush(&mut self, pos: [usize; 2], weights: WeightArray, value: f64){

        for y in (1-(EROSION_RADIUS as i32))..EROSION_RADIUS as i32{
            for x in (1-(EROSION_RADIUS as i32))..EROSION_RADIUS as i32{
                let x_pos = pos[0] as i32 + x;
                let y_pos = pos[1] as i32 + y;

                let size = self.noise_map.size();

                if x_pos >= 0 && x_pos < size.0 as i32 && y_pos >= 0 && y_pos < size.1 as i32 {
                    let weight = weights[(y + EROSION_RADIUS as i32 - 1) as usize][(x + EROSION_RADIUS as i32 - 1) as usize];
                    self.add_value(x_pos as usize, y_pos as usize, -value * weight);
                }
            }
        } 
    }

    pub fn save_to_file(&self, filename: &str) {
        self.noise_map.write_to_file(filename);
    }

}

struct HeightGradient {
    height: f64,
    gradient: [f64; 2]
}
