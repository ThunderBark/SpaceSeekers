class_name MissileLauncher
extends Position3D


export (PackedScene) var missile: PackedScene
export (float) var rate_of_fire: float = 5.0
export (float) var accuracy: float = 15.0

onready var world_root: Node = get_tree().get_root().get_child(0)
onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var cooldown : float = 0
var craft: KinematicBody


func _ready():
	rng.randomize()


func _physics_process(delta: float) -> void:
	if cooldown >= 0:
		cooldown -= delta

func fire_missile(pos: Vector3) -> void:
	if cooldown <= 0:
		cooldown = 1 / rate_of_fire
		
		var m = missile.instance()
		m.transform = global_transform
		m.shooter = craft
		var penalty: float = exp((pos - craft.translation).length() / accuracy)
		m.target_position = pos + Vector3(
			rand_range(-penalty, penalty),
			0.0,
			rand_range(-penalty, penalty)
		)
		world_root.add_child(m)
