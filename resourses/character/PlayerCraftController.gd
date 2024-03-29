class_name PlayerCraftController
extends Spatial

export(PackedScene) var building_bp: PackedScene
onready var blueprint: Spatial = building_bp.instance()
export(PackedScene) var extractor1: PackedScene
onready var extractor: Spatial = extractor1.instance()
export(Vector3) var camera_init_position: Vector3


export(int) var invul_msec: int = 10

onready var craft: KinematicBody = get_child(0)
onready var camera: Camera = get_node("Camera")

onready var weapons := $SpeederA/Hull/Weapons

var rng = RandomNumberGenerator.new()
var velocity: Vector3 = Vector3.ZERO
var is_building: bool = false

var max_hp: int = 100
var player_hp: int = max_hp
var last_damage_time: int = Time.get_ticks_msec()

var is_dead: bool = false
var is_arriving: bool = false

signal not_enough_funds_sig()


func _ready():
	for weapon in weapons.get_children():
		weapon.craft = craft

	PlayerState.player_hp_changed(player_hp)
	craft.connect("took_damage", self, "craft_took_damage")
	craft.add_to_group("player")

	blueprint.visible = false
	add_child(blueprint)


func play_arrival_cutscene():
	var tween: Tween = Tween.new()
	tween.interpolate_property(
		craft,
		"translation",
		craft.translation - craft.translation.direction_to(Vector3.ZERO) * 40 + Vector3.UP * 10,
		craft.translation,
		1.5,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)
	add_child(tween)
	tween.connect("tween_completed", self, "craft_arrived")
	tween.start()
	craft.hull.rotation.y = craft.transform.looking_at(Vector3.ZERO, Vector3.UP).basis.get_euler().y + PI	

	is_arriving = true


func craft_arrived(obj, key):
	craft.point_to_look = Vector3.ZERO
	is_arriving = false

func _physics_process(delta):
	## Camera offset
	camera.translation = lerp(
		camera.translation,
		(
			craft.translation +
			camera_init_position + (
				Vector3(
					(get_viewport().get_mouse_position().x - get_viewport().size.x / 2) / get_viewport().size.x,
					0,
					(get_viewport().get_mouse_position().y - get_viewport().size.y / 2) / get_viewport().size.y
				).rotated(
					Vector3.UP, -PI / 4
				) * 23
			)
		),
		1.5 * delta
	)

	if is_arriving:
		return

	## Move craft
	var dir: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("move_left"):
		dir.x -= 1.0
		dir.z -= 1.0
	if Input.is_action_pressed("move_right"):
		dir.x += 1.0
		dir.z += 1.0
	if Input.is_action_pressed("move_up"):
		dir.z -= 1.0
		dir.x += 1.0
	if Input.is_action_pressed("move_down"):
		dir.z += 1.0
		dir.x -= 1.0
	if Input.is_action_pressed("primary_fire_action"):
		try_fire_bullet()
	if Input.is_action_pressed("secondary_fire_action"):
		try_fire_missile()

	if craft is CraftController:
		craft.dir = dir.normalized()

		## Rotate speeder towards mouse position
		var drop_plane = Plane(Vector3(0, 1, 0), craft.translation.y)
		var mouse_position = drop_plane.intersects_ray(
			camera.project_ray_origin(get_viewport().get_mouse_position()),
			camera.project_ray_normal(get_viewport().get_mouse_position())
		)
		craft.point_to_look = mouse_position

	if PlayerState.player_mode == PlayerState.PLAYER_BUILDING:
		building_mode()
		blueprint.visible = true
	else:
		blueprint.visible = false



func try_fire_bullet() -> void:
	if PlayerState.player_mode == PlayerState.PLAYER_FIRING_BULLETS:
		for weapon in weapons.get_children():
			if weapon is Minigun:
				weapon.fire_bullet()


func try_fire_missile() -> void:
	if PlayerState.player_mode == PlayerState.PLAYER_FIRING_BULLETS:
		var mouse_position = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_position)
		var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 2000
		var space_state = get_world().direct_space_state
		var intersection = space_state.intersect_ray(ray_origin, ray_end, [self], (1 << 0))
		if not intersection.empty():
			for weapon in weapons.get_children():
				if weapon is MissileLauncher:
					weapon.fire_missile(intersection.position)


func building_mode():
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 2000
	var space_state = get_world().direct_space_state
	var intersection = space_state.intersect_ray(
		ray_origin, ray_end, [self, craft], (1 << 0) | (1 << 2)
	)
	if not intersection.empty():
		show_blueprint(intersection)


func craft_took_damage(damage_amount):
	var damage_time = Time.get_ticks_msec()
	if (((damage_time - last_damage_time) >= invul_msec)
		and not is_dead
		and not is_arriving):
		last_damage_time = damage_time

		player_hp -= damage_amount
		PlayerState.player_hp_changed(player_hp)
		if player_hp <= 0:
			blueprint.queue_free()
			is_dead = true
			set_physics_process(false)
			craft.die()
			PlayerState.player_died()


func has_enough_score_to_build() -> bool:
	if PlayerState.player_score >= PlayerState.extractor_cost:
		return true
	return false


func show_blueprint(intersection: Dictionary) -> void:
	if Input.is_action_just_pressed("move_ascend"):
		blueprint.rotate(Vector3.UP, -PI / 2)
	if Input.is_action_just_pressed("move_descend"):
		blueprint.rotate(Vector3.UP, PI / 2)

	var coll: Spatial = intersection.collider

	

	if not ((coll is Crystal) and (coll.is_vacant == true)):
		blueprint.red()
		blueprint.translation = intersection.position
		return
	
	blueprint.translation = coll.translation
	if blueprint.check_ground() and has_enough_score_to_build():
		blueprint.green()
	else:
		blueprint.red()
	
	if not (Input.is_action_just_pressed("primary_fire_action") and blueprint.check_ground()):
		return
	
	if has_enough_score_to_build():
		var extr: Spatial = extractor1.instance()
		extr.translation = coll.translation
		extr.rotation = blueprint.rotation
		extr.add_to_group("player")
		extr.crystal = coll
		get_parent().add_child(extr)
		coll.is_vacant = false
		PlayerState.player_buy_extractor()
	else:
		emit_signal("not_enough_funds_sig")
