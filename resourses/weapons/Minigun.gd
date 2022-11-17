extends Position3D


export (PackedScene) var bullet
export (float) var rate_of_fire = 5.0
var cooldown : float = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("primary_fire_action") and (PlayerState.player_state == PlayerState.PLAYER_FIRING_BULLETS):
		fire_bullet()
	
	if cooldown >= 0:
		cooldown -= delta

func fire_bullet() -> void:
	if cooldown <= 0:
		cooldown = 1 / rate_of_fire
		var b = bullet.instance()
		b.transform = global_transform
#		b.rotation.y += rng.randf_range(-0.05, 0.05)
#		b.transform = b.transform.translated(Vector3(0, 0, rng.randf_range(-0.1, 0.1)))
		b.shooter = self
		owner.add_child(b)
