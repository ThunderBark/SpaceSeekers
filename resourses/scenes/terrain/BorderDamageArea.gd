extends Area


func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body is CraftController:
			body.take_damage(1)
