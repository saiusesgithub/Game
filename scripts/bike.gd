class_name ArcadeBike
extends CharacterBody3D

signal crashed

const MAX_SPEED := 52.0
const ACCELERATION := 20.0
const COAST_DECELERATION := 9.0
const BRAKE_DECELERATION := 34.0
const MAX_X := 7.2

var speed := 0.0
var steering := 0.0
var active := true
var distance_travelled := 0.0
var visual: Node3D

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2
	_build_visual()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.0, 1.25, 2.65)
	collider.shape = shape
	collider.position.y = 0.85
	add_child(collider)

func reset_bike() -> void:
	global_position = Vector3(0.0, 0.0, 0.0)
	velocity = Vector3.ZERO
	speed = 0.0
	steering = 0.0
	active = true
	distance_travelled = 0.0
	visual.rotation = Vector3.ZERO

func stop() -> void:
	active = false
	speed = 0.0
	velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if not active:
		return
	var throttle: float = Input.get_action_strength("accelerate")
	var brake: float = Input.get_action_strength("brake")
	if throttle > 0.0:
		speed = move_toward(speed, MAX_SPEED, ACCELERATION * throttle * delta)
	elif brake > 0.0:
		speed = move_toward(speed, 0.0, BRAKE_DECELERATION * brake * delta)
	else:
		speed = move_toward(speed, 0.0, COAST_DECELERATION * delta)

	var target_steering: float = Input.get_axis("steer_left", "steer_right")
	steering = move_toward(steering, target_steering, 4.5 * delta)
	var steering_power: float = lerpf(2.5, 10.0, speed / MAX_SPEED)
	var lateral_speed: float = steering * steering_power * clampf(speed / 12.0, 0.0, 1.0)
	velocity = Vector3(lateral_speed, 0.0, -speed)
	move_and_slide()
	if _check_traffic_impact():
		return
	global_position.x = clamp(global_position.x, -MAX_X, MAX_X)
	distance_travelled += speed * delta

	visual.rotation.z = lerp(visual.rotation.z, -steering * 0.43 * clamp(speed / 10.0, 0.0, 1.0), 9.0 * delta)
	visual.rotation.y = lerp(visual.rotation.y, -steering * 0.10, 7.0 * delta)
	for index in get_slide_collision_count():
		var hit := get_slide_collision(index).get_collider()
		if hit != null and hit.is_in_group("traffic"):
			active = false
			speed = 0.0
			velocity = Vector3.ZERO
			crashed.emit()
			return

func _check_traffic_impact() -> bool:
	var traffic_nodes: Array[Node] = get_tree().get_nodes_in_group("traffic")
	for node: Node in traffic_nodes:
		var vehicle: Node3D = node as Node3D
		if vehicle == null:
			continue
		var delta_to_vehicle: Vector3 = global_position - vehicle.global_position
		if absf(delta_to_vehicle.x) < 1.35 and absf(delta_to_vehicle.z) < 2.65 and absf(delta_to_vehicle.y) < 1.6:
			active = false
			speed = 0.0
			velocity = Vector3.ZERO
			crashed.emit()
			return true
	return false

func speed_kph() -> int:
	return roundi(speed * 3.6)

func _make_material(color: Color, metallic := 0.0, roughness := 0.7) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	return material

func _box(size: Vector3, position: Vector3, material: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.material_override = material
	node.position = position
	return node

func _wheel(position: Vector3) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.34
	mesh.bottom_radius = 0.34
	mesh.height = 0.18
	node.mesh = mesh
	node.material_override = _make_material(Color(0.025, 0.025, 0.03), 0.1, 0.9)
	node.position = position
	node.rotation.z = deg_to_rad(90.0)
	return node

func _build_visual() -> void:
	visual = Node3D.new()
	visual.name = "BikeVisual"
	add_child(visual)
	var red := _make_material(Color(0.85, 0.06, 0.03), 0.25, 0.28)
	var dark := _make_material(Color(0.06, 0.07, 0.08), 0.45, 0.35)
	var metal := _make_material(Color(0.55, 0.58, 0.62), 0.85, 0.22)
	visual.add_child(_wheel(Vector3(0.0, 0.34, -1.04)))
	visual.add_child(_wheel(Vector3(0.0, 0.34, 1.02)))
	visual.add_child(_box(Vector3(0.76, 0.42, 1.25), Vector3(0.0, 0.86, 0.10), red))
	visual.add_child(_box(Vector3(0.52, 0.20, 0.62), Vector3(0.0, 1.18, -0.28), red))
	visual.add_child(_box(Vector3(0.60, 0.16, 0.62), Vector3(0.0, 1.13, 0.72), dark))
	visual.add_child(_box(Vector3(0.12, 0.12, 0.92), Vector3(0.0, 0.73, -0.63), metal))
	visual.add_child(_box(Vector3(1.02, 0.08, 0.10), Vector3(0.0, 1.42, -0.86), metal))
