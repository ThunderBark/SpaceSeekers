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
	for i in get_groups():
		if shooter.get_groups().has(i):
			return

	if not (shooter.is_in_group(get_groups()[0])):
		print("Extractor took damage: " + String(damage_amount))
		health -= damage_amount
		if health <= 0:
			$AnimationPlayer.play("Explosions")
			crystal.is_vacant = true


func _process(delta):
	var cur_tick: int = Time.get_ticks_msec()
	if is_in_group("player1") and (cur_tick - tick) >= 1000:
		tick = cur_tick
		PlayerState.player_score_increase_by_amount(10)
