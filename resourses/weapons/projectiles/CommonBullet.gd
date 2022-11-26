extends Area

export (int) var damage: int = 2

var speed = 50
var shooter
var lifetime : float = 3.0
var particle_time : float = 0.1

func _ready():
	$AudioStreamPlayer3D.pitch_scale = 0.75 + randf() * 0.5
	$AudioStreamPlayer3D.play()
	yield(get_tree().create_timer(2), "timeout")
	queue_free()

func _physics_process(delta):
	translation += transform.basis.z * speed * delta


func _on_Bullet_body_entered(body):
	if body != shooter:
		if body is CraftController:
			body.take_damage(damage)

		$MeshInstance.hide()
		$Particles.emitting = true
		yield(get_tree().create_timer(0.1), "timeout")
		queue_free()
