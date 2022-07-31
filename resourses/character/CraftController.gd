class_name CraftController
extends KinematicBody

export (float) var speed = 10
export (float) var inertia = 10
export (float) var inertia_momentum = 0.1

onready var mesh : MeshInstance = $Hull
onready var mesh_collision : CollisionShape = $HullCollision
onready var init_height: float = translation.y

var rng = RandomNumberGenerator.new()
var velocity : Vector3 = Vector3.ZERO
var dir : Vector3 = Vector3.ZERO
var point_to_look : Vector3 = Vector3.ZERO

func _ready():
	rng.randomize()


func _physics_process(delta):
	## Move craft
	translation.y = init_height
	velocity = velocity.linear_interpolate(dir * speed, 1.0 / inertia)
	move_and_slide(velocity, Vector3.UP)
	dir = Vector3.ZERO
	
	## Rotate speeder towards position
	if point_to_look != Vector3.ZERO:
		point_to_look -= translation
		var rot : float = point_to_look.angle_to(Vector3.BACK) * (
			sign(point_to_look.x) if sign(point_to_look.x) else 1
		)
		mesh.rotation.y = wrapf(
			lerp_angle(mesh.rotation.y, rot, 1 / inertia_momentum * delta),
			-PI,
			PI
		)
		
		## Tilt the ship according to rotation
		mesh.rotation.z = clamp(lerp_angle(
			mesh.rotation.z,
			(mesh.rotation.y - rot) * 3,
			5 * delta
		), -PI/4, PI/4)
		mesh_collision.rotation = mesh.rotation
	
