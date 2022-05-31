extends Spatial

const ADS_LERP = 20

export var default_pos : Vector3
export var ads_pos : Vector3

func _process(delta):
	if Input.is_action_pressed("ads"):
		transform.orgin = transform.orgin.linear_interpolate(ads_pos, ADS_LERP * delta)
	else:
		transform.origin = transform.orgin.linear_interpolate(default_pos, ADS_LERP * delta)
