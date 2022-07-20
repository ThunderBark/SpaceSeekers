extends Area


export (float) var speed = 10
var shooter
var target
var target_detected = false


# Called when the node enters the scene tree for the first time.
func _ready():
	die_deferred()

func _physics_process(delta):
	if target_detected && is_instance_valid(target):
		transform = transform.interpolate_with(transform.looking_at(target.translation, Vector3.UP), 0.05)
	translation += -transform.basis.z * speed * delta


func die_deferred():
	yield(get_tree().create_timer(2), "timeout")
	hide()
	set_physics_process(false)
	yield(get_tree().create_timer(2), "timeout")
	add_to_group("trash")


func _on_DetectionArea_body_entered(body):
	if body != shooter && !target_detected:
		target = body
		target_detected = true


func _on_Rocket_body_entered(body):
	if body != shooter:
		hide()
		set_physics_process(false)
