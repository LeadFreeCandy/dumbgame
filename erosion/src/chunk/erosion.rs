use gdnative::prelude::godot_print;
use noise::{Fbm, utils::PlaneMapBuilder, utils::NoiseMapBuilder, MultiFractal};
use rand::prelude::*;

const EROSION_RADIUS: u32 = 3; //2-8
const INERTIA: f64 = 0.1; // 0-1
const SEDIMENT_CAPACITY_FACTOR: f64 = 4.0;
const MIN_SEDIMENT_CAPACITY: f64 = 0.01;
const ERODE_SPEED: f64 = 0.3; //0-1
const DEPOSIT_SPEED: f64 = 0.3; //0-1
const EVAPORATION_SPEED: f64 = 0.01; //0-1
const GRAVITY: f64 = 4.0; //0-1
const MAX_DROPLET_LIFETIME: u32 = 30;

const NUM_ITERS: u32 = 2_000;

const INITIAL_WATER_VOLUME: f64 = 1.0;
const INITIAL_SPEED: f64 = 1.0;

const NOISE_SCALE: f64 = 5.0;
pub const TILE_SIZE: usize = 64;

type WeightArray = [[f64; EROSION_RADIUS as usize * 2 - 1]; EROSION_RADIUS as usize * 2 - 1];

enum Direction {
    Center,
    North,
    East,
    South,
    West,
}
use Direction::*;

pub struct ErosionMap {
    noise_map: noise::utils::NoiseMap
}

impl ErosionMap {
    pub fn new(x: i32, y: i32) -> ErosionMap {

        let corner = (x as f64 * NOISE_SCALE, y as f64 * NOISE_SCALE);

        let (start_x, end_x) = (corner.0, corner.0 + NOISE_SCALE + NOISE_SCALE * (1.0 / TILE_SIZE as f64));
        let (start_y, end_y) = (corner.1, corner.1 + NOISE_SCALE + NOISE_SCALE * (1.0 / TILE_SIZE as f64));

        // let noise_module = Fbm::new();
        let noise_module = Fbm::new()
                                .set_octaves(6)
                                .set_persistence(0.5)
                                .set_lacunarity(2.0);



        let noise_map = 
            PlaneMapBuilder::new(&noise_module)
            .set_size(TILE_SIZE + 1, TILE_SIZE + 1)
            .set_x_bounds(start_x, end_x)
            .set_y_bounds(start_y, end_y)
            .build();

        ErosionMap {
            noise_map
        }
    }

    pub fn erode(&mut self, north_map: &mut ErosionMap, east_map: &mut ErosionMap, south_map: &mut ErosionMap, west_map: &mut ErosionMap) {


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



        

        for _ in 0..NUM_ITERS {

            let mut current_map = Center;

            let size = self.noise_map.size(); //todo fix horrible range impl
            let mut droplet = Droplet::new([((rng.gen_range(0.0..1.0) * (size.0 - 1) as f64) as usize) as f64, ((rng.gen_range(0.0..1.0) * (size.0 - 1) as f64) as usize) as f64]);

            for _ in 0..MAX_DROPLET_LIFETIME {
                let node = [droplet.pos[0] as usize, droplet.pos[1] as usize];
                let cell_offset = [droplet.pos[0] - node[0] as f64, droplet.pos[1] - node[1] as f64];

                let grad = match current_map {
                    Center => {calc_height_gradient(&self.noise_map, &droplet)}
                    North => {calc_height_gradient(&north_map.noise_map, &droplet)}
                    South => {calc_height_gradient(&south_map.noise_map, &droplet)}
                    East => {calc_height_gradient(&east_map.noise_map, &droplet)}
                    West => {calc_height_gradient(&west_map.noise_map, &droplet)}
                };

                droplet.dir[0] = droplet.dir[0] * INERTIA - grad.gradient[0] * (1.0 - INERTIA);   
                droplet.dir[1] = droplet.dir[1] * INERTIA - grad.gradient[1] * (1.0 - INERTIA);

                let len = (droplet.dir[0] * droplet.dir[0] + droplet.dir[1] * droplet.dir[1]).sqrt();

                droplet.dir[0] = droplet.dir[0] / len;
                droplet.dir[1] = droplet.dir[1] / len;

                droplet.pos[0] += droplet.dir[0];
                droplet.pos[1] += droplet.dir[1];

                //stop if not moving or left map //todo check if drop stop moving 
                if len < 0.001 {
                    break;
                }

                // if droplet.pos[0] < 0.0 {
                //     current_noise_map = &mut west_map.noise_map;
                //     if !on_original {
                //         break;
                //     }
                //     on_original = false;
                //     droplet.pos[0] += TILE_SIZE as f64;
                //     godot_print!("west");
                // }
                if droplet.pos[0] > size.0 as f64{
                    if let current_map = Center {} else {break}
                    current_map = East;
                }
                if droplet.pos[1] < 0.0 {
                    if let current_map = Center {} else {break}
                    current_map = South;
                }
                if droplet.pos[1] > size.1 as f64{
                    if let current_map = Center {} else {break}
                    current_map = North;
                }
                if droplet.pos[0] < 0.0 {
                    if let current_map = Center {} else {break}
                    current_map = West;
                }
                

                let new_height = match current_map {
                    Center => {calc_height_gradient(&self.noise_map, &droplet).height}
                    North => {calc_height_gradient(&north_map.noise_map, &droplet).height}
                    South => {calc_height_gradient(&south_map.noise_map, &droplet).height}
                    East => {calc_height_gradient(&east_map.noise_map, &droplet).height}
                    West => {calc_height_gradient(&west_map.noise_map, &droplet).height}
                };
                
                // let new_height = calc_height_gradient(current_map, &droplet).height;
                let delta_height = new_height - grad.height;

                let sediment_capacity = (-delta_height * droplet.speed * droplet.water * SEDIMENT_CAPACITY_FACTOR).max(MIN_SEDIMENT_CAPACITY);

                if droplet.sediment > sediment_capacity || delta_height > 0.0 {
                    let amount_to_deposit = if delta_height > 0.0 {
                        (droplet.sediment).min(delta_height)
                    } else {
                        (droplet.sediment - sediment_capacity) * DEPOSIT_SPEED
                    };
                    droplet.sediment -= amount_to_deposit;

                    fn add_values(map:&mut noise::utils::NoiseMap, node: [usize; 2], cell_offset: [f64; 2], amount_to_deposit: f64) {
                        ErosionMap::add_value(map, node[0], node[1], amount_to_deposit * (1.0 - cell_offset[0]) * (1.0 - cell_offset[1]));
                        ErosionMap::add_value(map, node[0] + 1, node[1], amount_to_deposit * cell_offset[0] * (1.0 - cell_offset[1]));
                        ErosionMap::add_value(map, node[0], node[1] + 1, amount_to_deposit * (1.0 - cell_offset[0]) * cell_offset[1]);
                        ErosionMap::add_value(map, node[0] + 1, node[1] + 1, amount_to_deposit * cell_offset[0] * cell_offset[1]);
                    }

                    match current_map {
                        Center => {
                            add_values(&mut self.noise_map, node, cell_offset, amount_to_deposit);
                            //todo implement the edge stuff
                        },
                        North => {add_values(&mut north_map.noise_map, node, cell_offset, amount_to_deposit)},
                        South => {add_values(&mut south_map.noise_map, node, cell_offset, amount_to_deposit)},
                        East => {add_values(&mut east_map.noise_map, node, cell_offset, amount_to_deposit)},
                        West => {add_values(&mut west_map.noise_map, node, cell_offset, amount_to_deposit)}
                    }

                } else {
                    let amount_to_erode = ((sediment_capacity - droplet.sediment) * ERODE_SPEED).min(-delta_height);


                    match current_map {
                        Center => {
                            Self::apply_weighted_brush(&mut self.noise_map, node, weights, amount_to_erode);
                            Self::apply_weighted_brush(&mut north_map.noise_map, [node[0], node[1]-TILE_SIZE], weights, amount_to_erode);
                            Self::apply_weighted_brush(&mut south_map.noise_map, [node[0], node[1]+TILE_SIZE], weights, amount_to_erode);
                            Self::apply_weighted_brush(&mut east_map.noise_map, [node[0]-TILE_SIZE, node[1]], weights, amount_to_erode);
                            Self::apply_weighted_brush(&mut west_map.noise_map, [node[0]+TILE_SIZE, node[1]], weights, amount_to_erode);
                        },
                        North => {Self::apply_weighted_brush(&mut north_map.noise_map, node, weights, amount_to_erode);},
                        South => {Self::apply_weighted_brush(&mut south_map.noise_map, node, weights, amount_to_erode);},
                        East => {Self::apply_weighted_brush(&mut east_map.noise_map, node, weights, amount_to_erode);},
                        West => {Self::apply_weighted_brush(&mut west_map.noise_map, node, weights, amount_to_erode);}
                    }
                    // Self::apply_weighted_brush(&mut current_noise_map, node, weights, amount_to_erode);
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

    pub fn get_value(&self, x: usize, y: usize) -> f64 {
        self.noise_map.get_value(x, y)
    }

    fn add_value(current_noise_map: &mut noise::utils::NoiseMap, x: usize, y: usize, value: f64) {
        current_noise_map.set_value(x, y, current_noise_map.get_value(x, y) + value);
    }

    fn apply_weighted_brush(current_noise_map: &mut noise::utils::NoiseMap, pos: [usize; 2], weights: WeightArray, value: f64){

        for y in (1-(EROSION_RADIUS as i32))..EROSION_RADIUS as i32{
            for x in (1-(EROSION_RADIUS as i32))..EROSION_RADIUS as i32{
                let x_pos = pos[0] as i32 + x;
                let y_pos = pos[1] as i32 + y;

                let size = current_noise_map.size();

                if x_pos >= 0 && x_pos < size.0 as i32 && y_pos >= 0 && y_pos < size.1 as i32 {
                    let weight = weights[(y + EROSION_RADIUS as i32 - 1) as usize][(x + EROSION_RADIUS as i32 - 1) as usize];
                    Self::add_value(current_noise_map, x_pos as usize, y_pos as usize, -value * weight);
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