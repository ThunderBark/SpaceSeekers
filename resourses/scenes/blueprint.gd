extends Spatial

onready var box: MeshInstance = get_child(0)


func green():
	box.get_surface_material(0).albedo_color = Color(0, 1, 0, 0.5)


func red():
	box.get_surface_material(0).albedo_color = Color(1, 0, 0, 0.5)


func check_ground() -> bool:
	var space_state = get_world().direct_space_state
	var ray_origin = box.translation
	var ray_end = box.translation + Vector3.DOWN
	var intersection = space_state.intersect_ray(ray_origin, ray_end)

	if not intersection.empty():
		if intersection.collider is GridMap:
			var grid: GridMap = intersection.collider

			if (
				grid.get_cell_item(
					int(round(box.global_translation.x + 0.5)),
					int(round(global_translation.y * 2)),
					int(round(box.global_translation.z + 0.5))
				)
				== 0
			):
				if (
					grid.get_cell_item(
						int(round(box.global_translation.x - 0.5)),
						int(round(global_translation.y * 2)),
						int(round(box.global_translation.z - 0.5))
					)
					== 0
				):
					if (
						grid.get_cell_item(
							int(round(box.global_translation.x - 0.5)),
							int(round(global_translation.y * 2)),
							int(round(box.global_translation.z + 0.5))
						)
						== 0
					):
						if (
							grid.get_cell_item(
								int(round(box.global_translation.x + 0.5)),
								int(round(global_translation.y * 2)),
								int(round(box.global_translation.z - 0.5))
							)
							== 0
						):
							return true

	return false
