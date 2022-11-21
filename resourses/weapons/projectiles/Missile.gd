extends Area


export (float) var speed = 10.0
export (int) var damage = 100

var shooter: Spatial
var target: Spatial
var target_detected: bool = true
var target_position

var is_already_blow_up: bool = false

func _ready():
	die_deferred()

func _physics_process(delta):
	# if target_detected && is_instance_valid(target):
	# 	transform = transform.interpolate_with(transform.looking_at(target.translation, Vector3.UP), 0.05)
	if target_position != Vector3.ZERO:
		transform = transform.interpolate_with(transform.looking_at(target_position, Vector3.UP), 0.3)
	translation += -transform.basis.z * speed * delta


func die_deferred():
	yield(get_tree().create_timer(1), "timeout")
	target_position -= Vector3(0.0, 2.0, 0.0)
	yield(get_tree().create_timer(1), "timeout")
	queue_free()


func _on_Rocket_body_entered(body):
	if (body != shooter) and not is_already_blow_up:
		for body in $ExplosionArea.get_overlapping_bodies():
			if body is Extractor:
				body.take_damage(damage)
		is_already_blow_up = true

		$foamBulletB.visible = false
		$Trail.emitting = false
		$AnimationPlayer.play("Explosion")
		set_physics_process(false)
		yield(get_tree().create_timer(1), "timeout")
		queue_free()
