class_name EnemyCraftController
extends Node

export(NodePath) var grid_path: NodePath
export(SpatialMaterial) var enemy_material: SpatialMaterial
export(PackedScene) var extractor: PackedScene
export(Vector3) var player_start_pos: Vector3 = Vector3.ZERO
export(int) var max_health: int = 30
export(int) var health: int = 30
export(float) var world_size: float = 64.0

onready var craft: CraftController = $SpeederA
onready var attention_area: Area = craft.get_node("AttentionArea")
onready var grid: GridMap = get_node(grid_path)
onready var last_think_time: int = Time.get_ticks_msec()

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var speed: float = 100.0

var last_player_position: Vector3 = player_start_pos
var last_extractor_position: Vector3 = player_start_pos
var hiding_pos: Vector3
var ref_think_period: int = 300
var think_period: int = ref_think_period
var const_dir: Vector3 = Vector3.ZERO
var is_dead: bool = false

enum {
	FLEE,
	ATTACK,
	HUNT,
	HIDE
}
var cur_behaviour = FLEE

onready var weapons = $SpeederA/Hull/Weapons


func _ready():
	for weapon in weapons.get_children():
		weapon.craft = craft
	
	craft.set_team(enemy_material, "enemy")
	craft.connect("took_damage", self, "craft_took_damage")


func craft_took_damage(amount):
	if is_dead:
		return
	
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
	PlayerState.enemy_died()
	is_dead = true


func has_enough_score_to_build() -> bool:
	if PlayerState.enemy_score >= PlayerState.extractor_cost:
		return true
	return false


func is_player_nearby() -> CraftController:
	var player_detected: CraftController = null
	for body in attention_area.get_overlapping_bodies():
		if body.is_in_group("player") and (body is CraftController):
			last_player_position = body.translation
			player_detected = body
	return player_detected

func is_player_extractor_nearby() -> Extractor:
	var extr: Extractor = null
	for body in attention_area.get_overlapping_bodies():
		if body.is_in_group("player") and (body is Extractor):
			last_extractor_position = body.translation
			extr = body
	return extr


func is_beneficial_to_place_extractor() -> bool:
	var is_beneficial: bool = false

	if PlayerState.enemy_score >= (PlayerState.respawn_cost + PlayerState.extractor_cost):
		is_beneficial = true
	
	return is_beneficial


func prefered_crystal_pos(prefered_dir: Vector3) -> Crystal:
	var crystal: Crystal = null

	for body in attention_area.get_overlapping_bodies():
		if body is Crystal and body.is_vacant:
			crystal = body

	return crystal


func place_extractor(crystal: Crystal):
	var rotation_y = try_find_rotation(crystal.global_translation)
	if rotation_y == -1:
		return

	var extr: Spatial = extractor.instance()
	extr.translation = crystal.translation
	extr.rotate(Vector3.UP, rotation_y * PI/2)
	extr.crystal = crystal
	get_parent().add_child(extr)
	crystal.is_vacant = false
	extr.set_team(enemy_material, "enemy")
	PlayerState.enemy_buy_extractor()


func choose_direction_to_go() -> Vector3:
	var dir: Vector3 = Vector3.ZERO
	
	if health > max_health / 2:
		if is_player_nearby() != null:
			cur_behaviour = ATTACK
		else:
			cur_behaviour = HUNT
	else:
		if is_player_nearby() != null:
			cur_behaviour = FLEE
		else:
			if cur_behaviour != HIDE:
				hiding_pos = -last_player_position;
			cur_behaviour = HIDE
		

	# Player attraction / repulsion
	var dir_to_player: Vector3 = (
		craft.translation.direction_to(last_player_position).normalized()
		* world_size
		/ craft.translation.distance_to(last_player_position)
	) * 2.0
	if (cur_behaviour == FLEE) or (craft.translation.distance_to(last_player_position) < 10):
		dir -= dir_to_player
	elif cur_behaviour == ATTACK:
		dir += dir_to_player

	# Repulsion by borders
	if (craft.translation.distance_to(Vector3.ZERO) > ((world_size / 2) - 15)):
		dir -= (
			Vector3(craft.translation.x, 0, craft.translation.z).normalized()
			* 300.0
			/ exp(world_size / craft.translation.distance_to(Vector3.ZERO))
		)

	# Attraction to point of interest
	var poi_attraction: float = 500.0
	if cur_behaviour == HUNT:
		# Hunting for player extractor
		if last_extractor_position != Vector3.ZERO:
			# We have extractor to check
			dir += craft.translation.direction_to(last_extractor_position) * poi_attraction
		else:
			# Wandering around
			pass
		# if craft.translation.distance_to(last_extractor_position) < 5:
		# 	last_extractor_position = Vector3.ZERO
	elif cur_behaviour == HIDE:
		dir += craft.translation.direction_to(hiding_pos) * poi_attraction

	return dir.normalized()


func _think():
	var cur_msec: int = Time.get_ticks_msec()
	if cur_msec > (last_think_time + think_period):
		const_dir = choose_direction_to_go()
		last_think_time = cur_msec
	craft.dir = const_dir

	# Trying to place extractor
	var poi_crystal: Crystal = prefered_crystal_pos(Vector3.ZERO)
	if is_beneficial_to_place_extractor() and (poi_crystal != null):
		place_extractor(poi_crystal)

	# Point to look
	var extr: Extractor = is_player_extractor_nearby()
	if extr != null:
		# Look at extractor
		craft.point_to_look = Vector3(extr.translation.x, 0, extr.translation.z)
		# Fire missiles at extractor
		for weapon in weapons.get_children():
			if weapon is MissileLauncher:
				weapon.fire_missile(extr.translation)
	elif is_player_nearby() != null:
		# Look at player
		craft.point_to_look = (
			last_player_position 
			+ is_player_nearby().velocity 
			* (craft.translation.distance_to(last_player_position) * 0.03)
		)
		# Fire bullets at player		
		# for weapon in weapons.get_children():
		# 	if weapon is Minigun:
		# 		weapon.fire_bullet()
	else:
		# Look front
		craft.point_to_look = craft.translation + const_dir


func try_find_rotation(point: Vector3) -> int:
	for i in 4:
		var angle: float = i * PI / 2 + PI / 4
		if (grid.get_cell_item(
				int(round(point.x + sign(sin(angle)) * 0.5 + 0.5)),
				int(round(point.y * 2)),
				int(round(point.z + sign(cos(angle)) * 0.5 + 0.5))
			) == 0
		):
			if (grid.get_cell_item(
					int(round(point.x + sign(sin(angle)) * 0.5 - 0.5)),
					int(round(point.y * 2)),
					int(round(point.z + sign(cos(angle)) * 0.5 - 0.5))
				) == 0
			):
				if (grid.get_cell_item(
						int(round(point.x + sign(sin(angle)) * 0.5 - 0.5)),
						int(round(point.y * 2)),
						int(round(point.z + sign(cos(angle)) * 0.5 + 0.5))
					) == 0
				):
					if (grid.get_cell_item(
							int(round(point.x + sign(sin(angle)) * 0.5 + 0.5)),
							int(round(point.y * 2)),
							int(round(point.z + sign(cos(angle)) * 0.5 - 0.5))
						) == 0
					):
						return i
	return -1
