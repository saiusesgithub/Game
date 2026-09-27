extends Node3D

const BikeScript = preload("res://scripts/bike.gd")
const TrafficScript = preload("res://scripts/traffic_vehicle.gd")
const RoadScript = preload("res://scripts/road_segment.gd")
const CameraScript = preload("res://scripts/chase_camera.gd")
const HudScript = preload("res://scripts/hud.gd")

const ROAD_LENGTH: float = 80.0
const LANES: Array[float] = [-6.0, 0.0, 6.0]
const TRAFFIC_COLORS: Array[Color] = [
	Color(0.82, 0.11, 0.08), Color(0.08, 0.28, 0.76), Color(0.87, 0.68, 0.08),
	Color(0.17, 0.65, 0.38), Color(0.78, 0.78, 0.80)
]

var player: Variant
var camera: Variant
var hud: Variant
var roads: Array = []
var traffic: Array = []
var next_traffic_z: float = -100.0
var crashed: bool = false
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 20260927
	_build_world()
	_build_road_pool()
	_build_player()
	_build_traffic_pool()
	_build_hud()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart") and crashed:
		_restart()
	if player == null:
		return
	_recycle_roads()
	_recycle_traffic()
	hud.update_stats(player.speed_kph(), player.distance_travelled)

func _build_world() -> void:
	var environment: WorldEnvironment = WorldEnvironment.new()
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.34, 0.56, 0.78)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.72, 0.78, 0.86)
	env.ambient_light_energy = 0.65
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.environment = env
	add_child(environment)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, -28, 0)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 70.0
	add_child(sun)

func _build_road_pool() -> void:
	for i: int in range(5):
		var segment: Node3D = RoadScript.new()
		segment.position.z = -ROAD_LENGTH * i
		add_child(segment)
		roads.append(segment)

func _build_player() -> void:
	player = BikeScript.new()
	player.name = "PlayerBike"
	player.position = Vector3.ZERO
	add_child(player)
	player.crashed.connect(_on_player_crashed)
	camera = CameraScript.new()
	camera.name = "ChaseCamera"
	camera.player = player
	camera.current = true
	add_child(camera)
	camera.global_position = Vector3(0, 4.6, 10.5)

func _build_traffic_pool() -> void:
	for i: int in range(14):
		var vehicle: Variant = TrafficScript.new()
		vehicle.name = "TrafficVehicle_%02d" % i
		add_child(vehicle)
		traffic.append(vehicle)
		_place_vehicle_ahead(vehicle)

func _build_hud() -> void:
	hud = HudScript.new()
	add_child(hud)

func _recycle_roads() -> void:
	var lowest_z: float = roads[0].global_position.z
	for segment: Node3D in roads:
		lowest_z = minf(lowest_z, segment.global_position.z)
	for segment: Node3D in roads:
		if segment.global_position.z > player.global_position.z + ROAD_LENGTH * 0.5:
			segment.global_position.z = lowest_z - ROAD_LENGTH
			lowest_z = segment.global_position.z

func _recycle_traffic() -> void:
	for vehicle: Variant in traffic:
		if vehicle.global_position.z > player.global_position.z + 28.0:
			_place_vehicle_ahead(vehicle)

func _place_vehicle_ahead(vehicle: Variant, spacing: float = 0.0) -> void:
	var lane: float = _pick_clear_lane()
	var placement_z: float = next_traffic_z - spacing
	next_traffic_z = placement_z - rng.randf_range(22.0, 38.0)
	var traffic_speed: float = rng.randf_range(20.0, 34.0)
	var tint: Color = TRAFFIC_COLORS[rng.randi_range(0, TRAFFIC_COLORS.size() - 1)]
	vehicle.configure(lane, placement_z, traffic_speed, tint)

func _pick_clear_lane() -> float:
	var candidates: Array[float] = []
	for lane: float in LANES:
		var clear: bool = true
		for vehicle: Variant in traffic:
			if is_instance_valid(vehicle) and absf(vehicle.global_position.x - lane) < 0.2:
				if absf(vehicle.global_position.z - next_traffic_z) < 18.0:
					clear = false
					break
		if clear:
			candidates.append(lane)
	if candidates.is_empty():
		return LANES[rng.randi_range(0, LANES.size() - 1)]
	return candidates[rng.randi_range(0, candidates.size() - 1)]

func _on_player_crashed() -> void:
	crashed = true
	hud.show_crash()

func _restart() -> void:
	crashed = false
	player.reset_bike()
	hud.hide_crash()
	next_traffic_z = -100.0
	for i: int in traffic.size():
		_place_vehicle_ahead(traffic[i])
	for i: int in roads.size():
		roads[i].global_position.z = -ROAD_LENGTH * i
