extends KinematicBody

onready var nav = $"../Terrain"
export (NodePath) var camera_path

var path = []
var path_node = 0

var speed = 10
var camera : Camera


func _ready():
	camera = get_node(camera_path)


func _physics_process(delta):
	if Input.is_action_just_pressed("primary_fire_action"):
		var dropPlane = Plane(Vector3(0, 1, 0), 0.5)
		var mouse_position = get_viewport().get_mouse_position()
		var pos = dropPlane.intersects_ray(camera.project_ray_origin(mouse_position), camera.project_ray_normal(mouse_position))
		move_to(pos)
		if path.size() != 0:
			print("Path calculated!")
	
	if path_node < path.size():
		var dir = (path[path_node] - global_transform.origin) + Vector3(0, 0, 0.5)
		if dir.length() < 1:
			path_node += 1
		else:
			move_and_slide(dir.normalized() * speed, Vector3.UP)


func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0
