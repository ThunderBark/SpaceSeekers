class_name EnemyCraftController
extends Node

export(NodePath) var grid_path: NodePath
export(SpatialMaterial) var enemy_material: SpatialMaterial
export(PackedScene) var extractor1: PackedScene
export(Vector3) var player_start_pos: Vector3 = Vector3.ZERO
export(int) var max_health: int = 30
export(int) var health: int = 30
export(float) var world_size: float = 64.0

onready var extractor: Spatial
onready var craft: CraftController = $SpeederA
onready var attention_area: Area = craft.get_node("AttentionArea")
onready var grid: GridMap = get_node(grid_path)
onready var last_think_time: int = Time.get_ticks_msec()

var rng = RandomNumberGenerator.new()
var speed: float = 100.0

var last_player_position: Vector3 = player_start_pos
var last_extractor_position: Vector3 = Vector3.ZERO
var ref_think_period: int = 300
var think_period: int = ref_think_period
var const_dir: Vector3 = Vector3.ZERO

enum {
	FLEE,
	ATTACK,
}
var cur_behaviour = FLEE


func _ready():
	craft.connect("took_damage", self, "craft_took_damage")
	craft.set_team(enemy_material, "enemy")


func craft_took_damage(amount):
	print("Enemy took damage")
	health -= amount
	craft.set_hp(health, max_health)
	if health <= 0:
		craft.hide_hp_bar()
		die()


func _physics_process(delta):
	# for body in attention_area.get_overlapping_bodies():
	# 	if (body is CraftController) and (body.is_in_group("player1")):
	# 		var target_body_pos : Vector3 = body.translation
	# 		if craft is CraftController:
	# 			craft.dir = craft.translation.direction_to(target_body_pos)
	# 			craft.point_to_look = target_body_pos

	# 	if (body is Crystal) and (body.is_vacant == true) and has_enough_score_to_build():
	# 		var rotation_y = try_find_rotation(body.global_translation)
	# 		if rotation_y == -1:
	# 			return

	# 		extractor = extractor1.instance()
	# 		extractor.translation = body.translation
	# 		extractor.rotate(Vector3.UP, rotation_y * PI/2)
	# 		extractor.crystal = body
	# 		get_parent().add_child(extractor)
	# 		body.is_vacant = false
	# 		extractor.set_team(enemy_material, "enemy")
	# 		PlayerState.enemy_buy_extractor()

	_think()


func die():
	set_physics_process(false)
	craft.die()
	PlayerState.player_won()


func has_enough_score_to_build() -> bool:
	if PlayerState.enemy_score >= PlayerState.extractor_cost:
		return true
	return false


func is_player_nearby() -> bool:
	var player_detected: bool = false
	for body in $SpeederA/AttentionArea.get_overlapping_bodies():
		if body.is_in_group("player1") and (body is CraftController):
			last_player_position = body.translation
			player_detected = true
		if body.is_in_group("player1") and (body is Extractor):
			last_extractor_position = body.translation
	return player_detected


func is_beneficial_to_place_extractor() -> bool:
	return true


func prefered_crystal_pos(prefered_dir: Vector3) -> Vector3:
	var crystal_pos: Vector3 = Vector3.ZERO

	return crystal_pos


func choose_direction_to_go() -> Vector3:
	var dir: Vector3 = Vector3.ZERO
	is_player_nearby()

	# Player attraction / repulsion
	var dir_to_player: Vector3 = (
		craft.translation.direction_to(last_player_position).normalized()
		* world_size
		/ craft.translation.distance_to(last_player_position)
	)
	if (cur_behaviour == FLEE) or (craft.translation.distance_to(last_player_position) < 5):
		dir -= dir_to_player
	else:
		dir += dir_to_player

	# Repulsion by borders
	dir -= (
		Vector3(craft.translation.x, 0, craft.translation.z).normalized()
		* 75.0
		/ exp(world_size / craft.translation.distance_to(Vector3.ZERO))
	)

	# Attraction to point of interest
	var poi_dir: Vector3 = prefered_crystal_pos(dir)
	if is_beneficial_to_place_extractor() and (poi_dir != Vector3.ZERO):
		dir += craft.translation.direction_to(poi_dir)
	elif (
		craft.translation.distance_to(last_extractor_position)
		< craft.translation.distance_to(player_start_pos)
	):
		dir += craft.translation.direction_to(last_extractor_position)
	elif (
		craft.translation.distance_to(player_start_pos)
		< craft.translation.distance_to(last_extractor_position)
	):
		dir += craft.translation.direction_to(player_start_pos)
	
	return dir.normalized()


func _think():
	var cur_msec: int = Time.get_ticks_msec()
	if cur_msec > (last_think_time + think_period):
		const_dir = choose_direction_to_go()
		last_think_time = cur_msec
	craft.dir = const_dir

	# Point to look
	if is_player_nearby():
		craft.point_to_look = last_player_position
	else:
		craft.point_to_look = craft.translation + const_dir


func try_find_rotation(point: Vector3) -> int:
	for i in 4:
		var angle: float = i * PI / 2 + PI / 4
		if (
			grid.get_cell_item(
				int(round(point.x + sign(sin(angle)) * 0.5 + 0.5)),
				int(round(point.y * 2)),
				int(round(point.z + sign(cos(angle)) * 0.5 + 0.5))
			)
			== 0
		):
			if (
				grid.get_cell_item(
					int(round(point.x + sign(sin(angle)) * 0.5 - 0.5)),
					int(round(point.y * 2)),
					int(round(point.z + sign(cos(angle)) * 0.5 - 0.5))
				)
				== 0
			):
				if (
					grid.get_cell_item(
						int(round(point.x + sign(sin(angle)) * 0.5 - 0.5)),
						int(round(point.y * 2)),
						int(round(point.z + sign(cos(angle)) * 0.5 + 0.5))
					)
					== 0
				):
					if (
						grid.get_cell_item(
							int(round(point.x + sign(sin(angle)) * 0.5 + 0.5)),
							int(round(point.y * 2)),
							int(round(point.z + sign(cos(angle)) * 0.5 - 0.5))
						)
						== 0
					):
						return i
	return -1