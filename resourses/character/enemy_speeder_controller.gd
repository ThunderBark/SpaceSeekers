extends KinematicBody


export (NodePath) var mesh_path
export (NodePath) var attention_area_path

onready var mesh : MeshInstance = $mesh
onready var attention_area : Area = $AttentionArea

var rng = RandomNumberGenerator.new()

var speed : float = 100.0


func _physics_process(delta):
	if !attention_area.get_overlapping_bodies().empty():
		var dir : Vector3 = Vector3.ZERO
		var target_body_pos : Vector3 = attention_area.get_overlapping_bodies()[0].translation
		dir = translation.direction_to(target_body_pos)
		transform = transform.interpolate_with(transform.looking_at(target_body_pos, Vector3.UP), 0.1)
		rotation_degrees.x = 0
		if translation.distance_to(target_body_pos) > 3.0:
			move_and_slide(dir * speed * delta, Vector3.UP)
	else:
		pass
