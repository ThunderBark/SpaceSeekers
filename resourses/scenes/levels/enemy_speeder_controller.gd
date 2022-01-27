extends KinematicBody


var Bullet := preload("res://resourses/projectiles/CommonBullet.tscn")
var Rocket := preload("res://resourses/projectiles/CommonRocket.tscn")
var rng = RandomNumberGenerator.new()


func _physics_process(delta):
	shoot_bullet()


func shoot_rocket():
	if $RocketCooldown.is_stopped():
		var r = Rocket.instance()
		owner.add_child(r)
		r.transform = $mesh/Muzzle.global_transform
		r.rotate_y(PI)
		r.shooter = self
		$RocketCooldown.start()


func shoot_bullet():
	if $MinigunCooldown.is_stopped():
		var b = Bullet.instance()
		owner.add_child(b)
		b.transform = $mesh/Muzzle.global_transform
		b.rotation.y += rng.randf_range(-0.05, 0.05)
		b.transform = b.transform.translated(Vector3(0, 0, rng.randf_range(-0.1, 0.1)))
		b.shooter = self
		$MinigunSFX.play()
		$MinigunCooldown.start()
