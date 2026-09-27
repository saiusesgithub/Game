class_name TrafficVehicle
extends CharacterBody3D

var travel_speed := 25.0
var lane_x := 0.0
var color := Color.WHITE

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	add_to_group("traffic")
	_build_visual()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.1, 1.4, 4.3)
	collider.shape = shape
	collider.position.y = 0.75
	add_child(collider)

func configure(new_lane_x: float, new_z: float, new_speed: float, new_color: Color) -> void:
	lane_x = new_lane_x
	travel_speed = new_speed
	color = new_color
	global_position = Vector3(lane_x, 0.0, new_z)

func _physics_process(delta: float) -> void:
	global_position.z -= travel_speed * delta

func _make_material(tint: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.metallic = 0.15
	material.roughness = 0.45
	return material

func _build_visual() -> void:
	var body := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(2.05, 0.72, 4.05)
	body.mesh = body_mesh
	body.material_override = _make_material(color)
	body.position.y = 0.58
	add_child(body)
	var cabin := MeshInstance3D.new()
	var cabin_mesh := BoxMesh.new()
	cabin_mesh.size = Vector3(1.65, 0.58, 1.85)
	cabin.mesh = cabin_mesh
	cabin.material_override = _make_material(Color(0.10, 0.17, 0.22))
	cabin.position = Vector3(0.0, 1.15, -0.20)
	add_child(cabin)
	for x: float in [-0.9, 0.9]:
		for z: float in [-1.35, 1.35]:
			var wheel := MeshInstance3D.new()
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.30
			wheel_mesh.bottom_radius = 0.30
			wheel_mesh.height = 0.18
			wheel.mesh = wheel_mesh
			wheel.material_override = _make_material(Color(0.03, 0.03, 0.035))
			wheel.position = Vector3(x, 0.30, z)
			wheel.rotation.z = deg_to_rad(90.0)
			add_child(wheel)
