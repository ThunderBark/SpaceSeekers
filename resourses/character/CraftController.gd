class_name CraftController
extends KinematicBody

export (float) var speed = 10.0
export (float) var inertia = 10.0
export (float) var inertia_momentum = 0.1

onready var hull : MeshInstance = $Hull
onready var hull_collision : CollisionShape = $HullCollision
onready var hp_bar: TextureProgress = $Hull/Healthbar3D/Viewport/HPBar
onready var animation: AnimationPlayer = $AnimationPlayer

onready var init_height: float = translation.y

var velocity : Vector3 = Vector3.ZERO
var dir : Vector3 = Vector3.ZERO
var point_to_look : Vector3 = Vector3.ZERO

signal took_damage(damage_amount)


func _physics_process(delta):
	## Move craft
	translation.y = init_height
	velocity = velocity.linear_interpolate(dir * speed, 1.0 / inertia)
	velocity = move_and_slide(velocity, Vector3.UP)
	dir = Vector3.ZERO
	
	## Rotate speeder towards position
	if point_to_look != Vector3.ZERO:
		point_to_look -= translation
		var rot : float = point_to_look.angle_to(Vector3.BACK) * (
			sign(point_to_look.x) if sign(point_to_look.x) else 1.0
		)
		hull.rotation.y = wrapf(
			lerp_angle(hull.rotation.y, rot, 1 / inertia_momentum * delta),
			-PI,
			PI
		)
		
		## Tilt the ship according to rotation
		hull.rotation.z = clamp(lerp_angle(
			hull.rotation.z,
			(hull.rotation.y - rot) * 3,
			5 * delta
		), -PI/4, PI/4)

		hull_collision.rotation = hull.rotation


func take_damage(damage_amount : int):
	emit_signal("took_damage", damage_amount)


func set_hp(value: int, max_value: int):
	hp_bar.max_value = max_value
	hp_bar.value = value
	if is_in_group("enemy") and (max_value != value):
		hp_bar.visible = true


func hide_hp_bar():
	hp_bar.visible = false


func die():
	set_physics_process(false)
	hull_collision.disabled = true
	animation.play("Crash")


func set_team(material: Material, group: String):
	add_to_group(group)
	hull.set_surface_material(1, material)
