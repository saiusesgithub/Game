extends Camera3D
var player: Variant
var base_fov: float = 72.0
var time_alive: float = 0.0
func _ready() -> void:
	position = Vector3(0.0, 1.85, 1.00)
func _process(delta: float) -> void:
	if player == null: return
	time_alive += delta
	var r: float = clampf(float(player.speed) / float(player.MAX_SPEED), 0.0, 1.0)
	position = Vector3(player.steering * 0.035 * r, 1.85 + sin(time_alive * (8.0 + r * 12.0)) * 0.012 * r, 1.00)
	rotation.z = lerpf(rotation.z, -player.steering * 0.09 * r, 1.0 - exp(-7.0 * delta))
	fov = lerpf(fov, base_fov + r * 7.0, 1.0 - exp(-4.0 * delta))