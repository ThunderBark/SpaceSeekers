class_name CraftController
extends KinematicBody

export (float) var speed = 10.0
export (float) var inertia = 10.0
export (float) var inertia_momentum = 0.1

onready var mesh : MeshInstance = $Hull
onready var mesh_collision : CollisionShape = $HullCollision
onready var init_height: float = translation.y

# onready var craft_material: SpatialMaterial = $Hull.get_active_material()

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
		# mesh.look_at(point_to_look, Vector3.UP)
		# mesh.rotation.x = PI
		# mesh.rotation.z += PI
		point_to_look -= translation
		var rot : float = point_to_look.angle_to(Vector3.BACK) * (
			sign(point_to_look.x) if sign(point_to_look.x) else 1.0
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


func take_damage(damage_amount : int):
	emit_signal("took_damage", damage_amount)


func set_hp(value: int, max_value: int):
	$Hull/Healthbar3D/Viewport/HPBar.max_value = max_value
	$Hull/Healthbar3D/Viewport/HPBar.value = value
	if is_in_group("enemy") and (max_value != value):
		$Hull/Healthbar3D.visible = true


func hide_hp_bar():
	$Hull/Healthbar3D/Viewport/HPBar.visible = false


func die():
	set_physics_process(false)
	$HullCollision.disabled = true
	$AnimationPlayer.play("Crash")


func set_team(material: Material, group: String):
	add_to_group(group)
	$Hull.set_surface_material(1, material)
