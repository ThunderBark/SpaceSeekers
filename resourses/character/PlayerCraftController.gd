class_name PlayerCraftController
extends Spatial

export(PackedScene) var building_bp: PackedScene
onready var blueprint: Spatial = building_bp.instance()
export(PackedScene) var extractor1: PackedScene
onready var extractor: Spatial = extractor1.instance()

export (int) var invul_msec: int = 50

onready var craft: KinematicBody = get_child(0)
onready var camera: Camera = craft.get_node("Camera")
onready var camera_init_position: Vector3 = camera.translation

var rng = RandomNumberGenerator.new()
var velocity: Vector3 = Vector3.ZERO
var is_building: bool = false

var player_hp: int = 100
var last_damage_time : int = Time.get_ticks_msec()


func _ready():
	craft.connect("took_damage", self, "craft_took_damage")

	craft.add_to_group("player1")

	blueprint.visible = false
	add_child(blueprint)

func _physics_process(delta):
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
	
	## Camera offset
	camera.translation = lerp(
		camera.translation,
		camera_init_position + Vector3(
			(get_viewport().get_mouse_position().x - get_viewport().size.x/2)/get_viewport().size.x,
			0,
			(get_viewport().get_mouse_position().y - get_viewport().size.y/2)/get_viewport().size.y
		).rotated(Vector3.UP, -PI/4) * 23,
		1.5 * delta
	)


func building_mode():
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 2000
	var space_state = get_world().direct_space_state
	var intersection = space_state.intersect_ray(ray_origin, ray_end, [self, craft], (1 << 0)|(1 << 2))
	if not intersection.empty():
		show_blueprint(intersection)


func craft_took_damage(damage_amount):
	var damage_time = Time.get_ticks_msec()
	if (damage_time - last_damage_time) >= invul_msec:
		last_damage_time = damage_time
		
		player_hp -= damage_amount
		PlayerState.player_hp_changed(player_hp)
		if player_hp <= 0:
			set_physics_process(false)
			craft.die()


func show_blueprint(intersection: Dictionary) -> void:	
	if Input.is_action_just_pressed("move_ascend"):
		blueprint.rotate(Vector3.UP, PI / 2)
	if Input.is_action_just_pressed("move_descend"):
		blueprint.rotate(Vector3.UP, -PI / 2)

	var coll: Spatial = intersection.collider

	if (coll is Crystal) and (coll.is_vacant == true):
		blueprint.translation = coll.translation
		if blueprint.check_ground():
			if Input.is_action_just_pressed("primary_fire_action"):
				var extr: Spatial = extractor1.instance()
				extr.translation = coll.translation
				extr.rotation = blueprint.rotation
				extr.add_to_group("player1")
				extr.crystal = coll
				get_parent().add_child(extr)
				coll.is_vacant = false
			blueprint.green()
		else:
			blueprint.red()
	else:
		blueprint.red()
		blueprint.translation = intersection.position
