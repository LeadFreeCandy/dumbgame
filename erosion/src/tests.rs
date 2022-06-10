use super::*;

#[test]
fn test_full(){
    let mut map = ErosionMap::new(0.0, 1.0, 0.0, 1.0, 512, 512);
    map.save_to_file("start_image.png");

    map.erode(100_000);

    map.save_to_file("end_image.png");
}