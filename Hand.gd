extends Spatial

const ADS_LERP = 20

export var default_pos : Vector3
export var ads_pos : Vector3

signal on_ads
signal off_ads

func _process(delta):
	if Input.is_action_pressed("ads"):
		emit_signal("on_ads")
		transform.origin = transform.origin.linear_interpolate(ads_pos, ADS_LERP * delta)
	else:
		emit_signal("off_ads")
		transform.origin = transform.origin.linear_interpolate(default_pos, ADS_LERP * delta)
