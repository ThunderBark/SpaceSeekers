class_name Extractor
extends StaticBody

export(int) var max_health: int = 1000
export(int) var score_per_second: int = 10

onready var tick: int = Time.get_ticks_msec()

var crystal: Crystal
var health: int = max_health


func _ready():
	pass


func take_damage(damage_amount, shooter: Spatial):
	if is_in_group("enemy") and shooter.is_in_group("enemy"):
		return
	if is_in_group("player1") and shooter.is_in_group("player1"):
		return

	print("Extractor took damage: " + String(damage_amount))
	health -= damage_amount
	if health <= 0:
		$AnimationPlayer.play("Explosions")
		crystal.is_vacant = true


func set_team(material: Material, group: String):
	$ExtractorMesh/hangar_roundB.set_surface_material(0, material)
	$ExtractorMesh/satelliteDish.set_surface_material(4, material)
	add_to_group(group)


func _process(delta):
	var cur_tick: int = Time.get_ticks_msec()
	if (cur_tick - tick) >= 1000:
		tick = cur_tick
		if is_in_group("player1"):
			PlayerState.player_score_increase_by_amount(score_per_second)
		elif is_in_group("enemy"):
			PlayerState.enemy_score_increase_by_amount(score_per_second)
