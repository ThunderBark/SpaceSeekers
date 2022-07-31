extends Area

var speed = 50
var shooter
var death : bool = false
var lifetime : float = 3.0
var particle_time : float = 0.1

func _ready():
	pass

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if not death:
		translation += transform.basis.z * speed * delta
	else:
		if particle_time > 0:
			particle_time -= delta
		else:
			queue_free()
	
	if lifetime > 0:
		lifetime -= delta
	else:
		queue_free()


func _on_Bullet_body_entered(body):
	if body != shooter:
		$MeshInstance.hide()
		$Particles.emitting = true
		death = true
