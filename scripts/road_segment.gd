class_name RoadSegment
extends Node3D

const LENGTH := 80.0
const ROAD_WIDTH := 18.0

func _ready() -> void:
	_build_segment()

func _material(color: Color, roughness := 0.8) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material

func _box(size: Vector3, pos: Vector3, mat: Material) -> void:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.material_override = mat
	node.position = pos
	add_child(node)

func _build_segment() -> void:
	_box(Vector3(ROAD_WIDTH, 0.16, LENGTH), Vector3(0, -0.08, 0), _material(Color(0.055, 0.06, 0.07)))
	_box(Vector3(3.5, 0.10, LENGTH), Vector3(-10.75, -0.03, 0), _material(Color(0.18, 0.22, 0.14)))
	_box(Vector3(3.5, 0.10, LENGTH), Vector3(10.75, -0.03, 0), _material(Color(0.18, 0.22, 0.14)))
	_box(Vector3(0.35, 0.12, LENGTH), Vector3(-8.82, 0.02, 0), _material(Color(0.85, 0.78, 0.35)))
	_box(Vector3(0.35, 0.12, LENGTH), Vector3(8.82, 0.02, 0), _material(Color(0.85, 0.78, 0.35)))
	for z in range(-36, 40, 8):
		_box(Vector3(0.22, 0.08, 3.8), Vector3(-3.0, 0.03, z), _material(Color(0.92, 0.92, 0.84)))
		_box(Vector3(0.22, 0.08, 3.8), Vector3(3.0, 0.03, z), _material(Color(0.92, 0.92, 0.84)))
