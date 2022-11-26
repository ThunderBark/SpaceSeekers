extends Position3D

export(PackedScene) var bullet
export(float) var rate_of_fire = 5.0
var cooldown: float = 0

onready var craft: KinematicBody = get_parent().get_parent().get_parent()
onready var world_root: Node = get_tree().get_root().get_child(0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (
		Input.is_action_pressed("primary_fire_action")
		and (PlayerState.player_mode == PlayerState.PLAYER_FIRING_BULLETS)
		and craft.is_in_group("player1")
	):
		fire_bullet()

	if cooldown >= 0:
		cooldown -= delta


func fire_bullet() -> void:
	if cooldown <= 0:
		cooldown = 1 / rate_of_fire
		var b = bullet.instance()
		b.transform = global_transform
		b.rotation.y += rand_range(-0.02, 0.02)
		b.transform = b.transform.translated(Vector3(0, 0, rand_range(-0.1, 0.1)))
		b.shooter = craft
		world_root.add_child(b)

