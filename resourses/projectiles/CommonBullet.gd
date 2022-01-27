extends Area

var speed = 50
var shooter

func _ready():
	die_deferred()

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	#translate_object_local(-transform.basis.z * speed * delta)
	translation += transform.basis.z * speed * delta


func die_deferred():
	yield(get_tree().create_timer(1), "timeout")
	hide()
	set_physics_process(false)
	add_to_group("trash")


func _on_Bullet_body_entered(body):
	if body != shooter:
		body.queue_free()
		hide()
		set_physics_process(false)
