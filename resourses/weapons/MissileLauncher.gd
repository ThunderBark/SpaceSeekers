extends Position3D


export (PackedScene) var missile
export (float) var rate_of_fire = 5.0
export (float) var accuracy = 15.0
var cooldown : float = 0

onready var craft: Spatial = get_parent().get_parent().get_parent()

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("secondary_fire_action") and (PlayerState.player_mode == PlayerState.PLAYER_FIRING_BULLETS):
		fire_missile()
	
	if cooldown >= 0:
		cooldown -= delta

func fire_missile() -> void:
	if cooldown <= 0:
		cooldown = 1 / rate_of_fire

		var mouse_position = get_viewport().get_mouse_position()
		var camera: Camera = get_viewport().get_camera()
		var ray_origin = camera.project_ray_origin(mouse_position)
		var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 2000
		var space_state = get_world().direct_space_state
		var intersection = space_state.intersect_ray(ray_origin, ray_end, [self], (1 << 0))
		if not intersection.empty():
			var m = missile.instance()
			m.transform = global_transform
			m.shooter = craft
			var penalty: float = exp((intersection.position - craft.translation).length() / accuracy)
			m.target_position = intersection.position + Vector3(
				rand_range(-penalty, penalty),
				0,
				rand_range(-penalty, penalty)
			)
			owner.add_child(m)
