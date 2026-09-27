extends Camera3D

var player: Variant
var base_fov: float = 65.0

func _process(delta: float) -> void:
	if player == null:
		return
	var desired: Vector3 = player.global_position + Vector3(0.0, 4.6, 10.5)
	global_position = global_position.lerp(desired, 1.0 - exp(-6.0 * delta))
	var look_target: Vector3 = player.global_position + Vector3(0.0, 1.0, -15.0)
	look_at(look_target, Vector3.UP)
	var speed_ratio: float = float(player.speed) / float(player.MAX_SPEED)
	fov = lerpf(fov, base_fov + speed_ratio * 9.0, 1.0 - exp(-4.0 * delta))
