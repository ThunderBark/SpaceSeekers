class_name Minigun
extends Position3D

export(PackedScene) var bullet: PackedScene
export(float) var rate_of_fire: float = 5.0

onready var world_root: Node = get_tree().get_root().get_child(0)

var cooldown: float = 0
var craft: KinematicBody


func _process(delta: float) -> void:
	if cooldown >= 0:
		cooldown -= delta


func fire_bullet() -> void:
	if cooldown <= 0:
		cooldown = 1 / rate_of_fire
		var b = bullet.instance()
		b.transform = global_transform
		b.rotation.y += rand_range(-0.04, 0.04)
		b.transform = b.transform.translated(Vector3(0, 0, rand_range(-0.1, 0.1)))
		b.shooter = craft
		world_root.add_child(b)

