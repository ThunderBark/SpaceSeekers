class_name EnemyCraftController
extends Node

export(NodePath) var grid_path: NodePath
export(SpatialMaterial) var enemy_material: SpatialMaterial
export(PackedScene) var extractor: PackedScene
export(Vector3) var player_start_pos: Vector3 = Vector3.ZERO
export(int) var max_health: int = 100
export(int) var health: int = 100
export(float) var world_size: float = 64.0
export(float) var accuracy: float = 7.0

onready var craft: CraftController = $SpeederA
onready var attention_area: Area = craft.get_node("AttentionArea")
onready var grid: GridMap = get_node(grid_path)
onready var weapons = $SpeederA/Hull/Weapons

onready var last_think_time: int = Time.get_ticks_msec()

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var speed: float = 100.0

var last_player_position: Vector3 = player_start_pos
var last_player_health: int = max_health
var last_extractor_position: Vector3 = player_start_pos
var random_position: Vector3 = Vector3.ZERO
var hiding_pos: Vector3
var ref_think_period: int = 300
var think_period: int = ref_think_period
var const_dir: Vector3 = Vector3.ZERO
var is_dead: bool = false

const BUILD_DELAY: int = 60
var cur_build_delay: int = BUILD_DELAY

var accuracy_point: Vector3 = Vector3.ZERO
var is_arriving: bool = false

enum {
	FLEE,
	ATTACK,
	HUNT,
	HIDE
}
var cur_behaviour = FLEE


func play_arrival_cutscene():
	var tween: Tween = Tween.new()
	tween.interpolate_property(
		craft,
		"translation",
		craft.translation - craft.translation.direction_to(Vector3.ZERO) * 20,
		craft.translation,
		3.0,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)
	add_child(tween)
	tween.connect("tween_completed", self, "craft_arrived")
	tween.start()
	craft.hull.rotation.y = craft.hull.transform.looking_at(Vector3.ZERO, Vector3.UP).basis.get_euler().y

	is_arriving = true


func craft_arrived(obj, key):
	craft.point_to_look = Vector3.ZERO
	is_arriving = false

func _ready():
	for weapon in weapons.get_children():
		weapon.craft = craft
	
	craft.set_team(enemy_material, "enemy")
	craft.connect("took_damage", self, "craft_took_damage")


func craft_took_damage(amount):
	if is_dead or is_arriving:
		return
	
	health -= amount
	craft.set_hp(health, max_health)
	if health <= 0:
		craft.hide_hp_bar()
		die()


func _physics_process(delta):
	_think(delta)


func die():
	PlayerState.enemy_last_extractor_pos = last_extractor_position
	PlayerState.enemy_last_player_pos = last_player_position
	PlayerState.enemy_last_player_health = last_player_health

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
			last_player_health = body.get_parent().player_hp
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


func place_extractor(crystal: Crystal) -> bool:
	var rotation_y = try_find_rotation(crystal.global_translation)
	if rotation_y == -1:
		cur_build_delay = BUILD_DELAY
		return false
	
	if (cur_build_delay > 0):
		return false

	var extr: Spatial = extractor.instance()
	extr.translation = crystal.translation
	extr.rotate(Vector3.UP, rotation_y * PI/2)
	extr.crystal = crystal
	get_parent().add_child(extr)
	crystal.is_vacant = false
	extr.set_team(enemy_material, "enemy")
	PlayerState.enemy_buy_extractor()

	return true


func choose_direction_to_go() -> Vector3:
	var dir: Vector3 = Vector3.ZERO
	
	if not ((last_player_health - health) > (max_health / 2)):
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
			random_position = Vector3.ZERO
			# We have extractor to check
			dir += craft.translation.direction_to(last_extractor_position) * poi_attraction
		elif last_player_position != Vector3.ZERO:
			random_position = Vector3.ZERO
			# Moving towards player
			dir += craft.translation.direction_to(last_player_position) * poi_attraction
		else:
			# Moving at random position
			if random_position == Vector3.ZERO:
				random_position = Vector3(
					randf() * Settings.world_size - (Settings.world_size / 2),
					craft.translation.y,
					randf() * Settings.world_size - (Settings.world_size / 2)
				)
			dir += craft.translation.direction_to(random_position) * poi_attraction
		
		if craft.translation.distance_to(last_extractor_position) < 5:
			last_extractor_position = Vector3.ZERO
		if craft.translation.distance_to(last_player_position) < 5:
			last_player_position = Vector3.ZERO
		if craft.translation.distance_to(random_position) < 5:
			random_position = Vector3.ZERO
	elif cur_behaviour == HIDE:
		if hiding_pos != Vector3.ZERO:
			dir += craft.translation.direction_to(hiding_pos) * poi_attraction
	
		if craft.translation.distance_to(hiding_pos) < 5:
			hiding_pos = Vector3.ZERO
	return dir.normalized()


func _think(delta: float):
	var cur_msec: int = Time.get_ticks_msec()
	if cur_msec > (last_think_time + think_period):
		const_dir = choose_direction_to_go()
		last_think_time = cur_msec
	craft.dir = const_dir

	# Trying to place extractor
	var poi_crystal: Crystal = prefered_crystal_pos(Vector3.ZERO)
	if is_beneficial_to_place_extractor() and (poi_crystal != null):
		craft.point_to_look = poi_crystal.translation
		cur_build_delay -= delta
		if (place_extractor(poi_crystal)):
			cur_build_delay = BUILD_DELAY
		return

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
		accuracy_point = accuracy_point.linear_interpolate(
			is_player_nearby().velocity * (craft.translation.distance_to(last_player_position) * 0.03),
			delta * accuracy
		)
		# Look at player
		craft.point_to_look = (last_player_position + accuracy_point)
		# Fire bullets at player		
		for weapon in weapons.get_children():
			if weapon is Minigun:
				weapon.fire_bullet()
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


func _on_AttentionArea_area_entered(area: Area):
	if (area is Missile) or (area is Bullet):
		if area.shooter.is_in_group("player"):
			last_player_position = area.shooter.translation
			last_player_health = area.shooter.get_parent().player_hp
			cur_behaviour = FLEE
