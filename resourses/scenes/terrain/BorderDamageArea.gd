extends Area


func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body is CraftController:
			body.take_damage(1)

	# if !attention_area.get_overlapping_bodies().empty():
	# 	var target_body_pos : Vector3 = attention_area.get_overlapping_bodies()[0].translation
	# 	if craft is CraftController:
	# 		craft.dir = craft.translation.direction_to(target_body_pos)
	# 		craft.point_to_look = target_body_pos
