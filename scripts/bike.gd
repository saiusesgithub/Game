class_name ArcadeBike
extends CharacterBody3D

signal crashed

const MAX_SPEED := 52.0
const ACCELERATION := 20.0
const COAST_DECELERATION := 9.0
const BRAKE_DECELERATION := 34.0
const MAX_X := 7.2
const BikeModelScene = preload("res://assets/bikes/bike-2/Bike3.glb")

var speed := 0.0
var steering := 0.0
var active := true
var distance_travelled := 0.0
var visual: Node3D
var steering_visual: Node3D

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

	var lean_amount: float = -steering * deg_to_rad(15.0) * clampf(speed / 10.0, 0.0, 1.0)
	visual.rotation.z = lerpf(visual.rotation.z, lean_amount, 1.0 - exp(-9.0 * delta))
	visual.rotation.y = lerpf(visual.rotation.y, -steering * deg_to_rad(4.0), 1.0 - exp(-7.0 * delta))
	if steering_visual != null:
		var speed_ratio: float = clampf(speed / MAX_SPEED, 0.0, 1.0)
		var steering_limit: float = deg_to_rad(lerpf(15.0, 4.0, speed_ratio))
		steering_visual.rotation.y = lerpf(steering_visual.rotation.y, -steering * steering_limit, 1.0 - exp(-10.0 * delta))
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
	visual.name = "CockpitModelRoot"
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
	visual.add_child(_box(Vector3(1.35,0.32,1.55),Vector3(0,0.94,-1.45),red))
	visual.add_child(_box(Vector3(1.55,0.10,0.12),Vector3(0,1.38,-1.12),metal))
	visual.add_child(_box(Vector3(0.42,0.12,0.16),Vector3(-0.92,1.40,-1.12),dark))
	visual.add_child(_box(Vector3(0.42,0.12,0.16),Vector3(0.92,1.40,-1.12),dark))
	visual.add_child(_box(Vector3(0.42,0.26,0.08),Vector3(-0.95,1.70,-1.40),dark))
	visual.add_child(_box(Vector3(0.42,0.26,0.08),Vector3(0.95,1.70,-1.40),dark))
	visual.add_child(_box(Vector3(0.48,0.20,0.12),Vector3(0,1.46,-1.22),dark))
	for child: Node in visual.get_children():
		if child is MeshInstance3D:
			child.visible = false
	var imported_model: Node3D = BikeModelScene.instantiate()
	imported_model.name = "Bike3Model"
	imported_model.position = Vector3(0.0, -0.72, 0.0)
	imported_model.rotation_degrees = Vector3(0.0, 90.0, 0.0)
	imported_model.scale = Vector3.ONE
	visual.add_child(imported_model)
	_create_steering_visual(imported_model)

func _create_steering_visual(imported_model: Node3D) -> void:
	steering_visual = Node3D.new()
	steering_visual.name = "SteeringVisualRoot"
	steering_visual.position = Vector3(1.679, 1.45, 0.0)
	imported_model.add_child(steering_visual)
	for child_name: String in ["Front", "Fork"]:
		var assembly_part := imported_model.get_node_or_null(child_name) as Node3D
		if assembly_part == null:
			continue
		var preserved_global_transform: Transform3D = assembly_part.global_transform
		imported_model.remove_child(assembly_part)
		steering_visual.add_child(assembly_part)
		assembly_part.global_transform = preserved_global_transform
