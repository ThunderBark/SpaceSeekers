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
var last_extractor_position: Vector3 = player_start_pos
var ref_think_period: int = 300
var think_period: int = ref_think_period
var const_dir: Vector3 = Vector3.ZERO

enum {
	FLEE,
	ATTACK,
	HUNT
}
var cur_behaviour = FLEE


signal shoot_bullet()
signal shoot_missle(pos)


func _ready():
	connect("shoot_bullet", $SpeederA/Hull/Weapons/Minigun, "fire_bullet")
	connect("shoot_bullet", $SpeederA/Hull/Weapons/Minigun2, "fire_bullet")
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
	var is_beneficial: bool = true
	if PlayerState.enemy_score > PlayerState.player_score:
		is_beneficial = true
	return is_beneficial


func prefered_crystal_pos(prefered_dir: Vector3) -> Crystal:
	var crystal: Crystal = null

	for body in $SpeederA/AttentionArea.get_overlapping_bodies():
		if body is Crystal and body.is_vacant:
			crystal = body

	return crystal


func place_extractor(crystal: Crystal):
	var rotation_y = try_find_rotation(crystal.global_translation)
	if rotation_y == -1:
		return

	extractor = extractor1.instance()
	extractor.translation = crystal.translation
	extractor.rotate(Vector3.UP, rotation_y * PI/2)
	extractor.crystal = crystal
	get_parent().add_child(extractor)
	crystal.is_vacant = false
	extractor.set_team(enemy_material, "enemy")
	PlayerState.enemy_buy_extractor()


func choose_direction_to_go() -> Vector3:
	var dir: Vector3 = Vector3.ZERO
	
	if is_player_nearby():
		if health > max_health / 2:
			cur_behaviour = ATTACK
		else:
			cur_behaviour = FLEE
	else:
		cur_behaviour = HUNT

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
		* 100.0
		/ exp(world_size / craft.translation.distance_to(Vector3.ZERO))
	)

	# Attraction to point of interest
	var poi_attraction: float = 50.0
	var poi_crystal: Crystal = prefered_crystal_pos(dir)
	if is_beneficial_to_place_extractor() and (poi_crystal != null):
		if PlayerState.enemy_score >= PlayerState.extractor_cost:
			place_extractor(poi_crystal)
		dir += craft.translation.direction_to(poi_crystal.translation)
	
	if cur_behaviour == HUNT:
		dir += craft.translation.direction_to(last_extractor_position) * poi_attraction * 10

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

		if cur_behaviour == ATTACK:
			emit_signal("shoot_bullet")
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