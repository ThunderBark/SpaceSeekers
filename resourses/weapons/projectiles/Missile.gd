extends Area


export (float) var speed = 10.0
var shooter: Spatial
var target: Spatial
var target_detected: bool = true
var target_position


func _ready():
	die_deferred()

func _physics_process(delta):
	# if target_detected && is_instance_valid(target):
	# 	transform = transform.interpolate_with(transform.looking_at(target.translation, Vector3.UP), 0.05)
	if target_position != Vector3.ZERO:
		transform = transform.interpolate_with(transform.looking_at(target_position, Vector3.UP), 0.3)
	translation += -transform.basis.z * speed * delta


func die_deferred():
	yield(get_tree().create_timer(2), "timeout")
	hide()
	set_physics_process(false)
	yield(get_tree().create_timer(2), "timeout")
	add_to_group("trash")


func _on_Rocket_body_entered(body):
	if body != shooter:
		for body in $ExplosionArea.get_overlapping_bodies():
			pass # Do damage

		$foamBulletB.visible = false
		$Trail.emitting = false
		$AnimationPlayer.play("Explosion")
		set_physics_process(false)
