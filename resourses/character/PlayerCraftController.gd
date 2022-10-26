class_name PlayerCraftController
extends Spatial


onready var craft : KinematicBody = get_child(0)
onready var camera : Camera = craft.get_node("Camera")
onready var camera_init_position : Vector3 = camera.translation

var rng = RandomNumberGenerator.new()
var velocity : Vector3 = Vector3.ZERO

func _ready():
	rng.randomize()


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
	var space_state = get_world().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 2000
	var intersection = space_state.intersect_ray(ray_origin, ray_end, [self])
	if not intersection.empty():
		craft.point_to_look = intersection.position
	else:
		var dropPlane = Plane(Vector3(0, 1, 0), craft.translation.y)
		mouse_position = dropPlane.intersects_ray(
			camera.project_ray_origin(get_viewport().get_mouse_position()),
			camera.project_ray_normal(get_viewport().get_mouse_position())
		)
		craft.point_to_look = mouse_position
	

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
