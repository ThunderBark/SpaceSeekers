extends KinematicBody


export (NodePath) var mesh_path
export (NodePath) var muzzle_path
export (NodePath) var rocket_cooldown_path
export (NodePath) var minigun_cooldown_path
export (NodePath) var attention_area_path

var mesh : MeshInstance
var muzzle : Position3D
var rocket_cooldown : Timer
var minigun_cooldown : Timer
var attention_area : Area

var Bullet := preload("res://resourses/projectiles/CommonBullet.tscn")
var Rocket := preload("res://resourses/projectiles/CommonRocket.tscn")
var rng = RandomNumberGenerator.new()

var speed : float = 100.0


func _ready():
	mesh = get_node(mesh_path)
	muzzle = get_node(muzzle_path)
	rocket_cooldown = get_node(rocket_cooldown_path)
	minigun_cooldown = get_node(minigun_cooldown_path)
	attention_area = get_node(attention_area_path)


func _physics_process(delta):
	if !attention_area.get_overlapping_bodies().empty():
		var dir : Vector3 = Vector3.ZERO
		var target_body_pos : Vector3 = attention_area.get_overlapping_bodies()[0].translation
		dir = translation.direction_to(target_body_pos)
		transform = transform.interpolate_with(transform.looking_at(target_body_pos, Vector3.UP), 0.1)
		rotation_degrees.x = 0
		if translation.distance_to(target_body_pos) > 3.0:
			move_and_slide(dir * speed * delta, Vector3.UP)
	else:
		pass


func shoot_rocket():
	if rocket_cooldown.is_stopped():
		var r = Rocket.instance()
		owner.add_child(r)
		r.transform = muzzle.global_transform
		r.rotate_y(PI)
		r.shooter = self
		rocket_cooldown.start()


func shoot_bullet():
	if minigun_cooldown.is_stopped():
		var b = Bullet.instance()
		owner.add_child(b)
		b.transform = muzzle.global_transform
		b.rotation.y += rng.randf_range(-0.05, 0.05)
		b.transform = b.transform.translated(Vector3(0, 0, rng.randf_range(-0.1, 0.1)))
		b.shooter = self
		$MinigunSFX.play()
		minigun_cooldown.start()
