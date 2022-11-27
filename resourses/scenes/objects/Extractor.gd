class_name Extractor
extends StaticBody

export(Texture) var enemy_health_bar_text: Texture
export(int) var max_health: int = 1000
export(int) var score_per_second: int = 10

onready var tick: int = Time.get_ticks_msec()

var crystal: Crystal
var health: int = max_health
var is_dead: bool = false


func _ready():
	$AnimationPlayer.play("Construction")


func take_damage(damage_amount, shooter: Spatial):
	if is_in_group("enemy") and shooter.is_in_group("enemy"):
		return
	if is_in_group("player1") and shooter.is_in_group("player1"):
		return

	print("Extractor took damage: " + String(damage_amount))
	health -= damage_amount

	$ExtractorMesh/Healthbar3D/Viewport/HPBar.max_value = max_health
	$ExtractorMesh/Healthbar3D/Viewport/HPBar.value = health
	$ExtractorMesh/Healthbar3D.visible = true

	if health <= 0 and !is_dead:
		is_dead = true
		if is_in_group("enemy"):
			PlayerState.player_score_increase_by_amount(50)
		elif is_in_group("player1"):
			PlayerState.enemy_score_increase_by_amount(50)
		$AnimationPlayer.play("Explosions")
		$ExtractorMesh/Healthbar3D.visible = false
		crystal.is_vacant = true


func set_team(material: Material, group: String):
	$ExtractorMesh/hangar_roundB.set_surface_material(0, material)
	$ExtractorMesh/satelliteDish.set_surface_material(4, material)
	add_to_group(group)
	if group in "enemy":
		$ExtractorMesh/Healthbar3D/Viewport/HPBar.texture_progress = enemy_health_bar_text


func _process(delta):
	var cur_tick: int = Time.get_ticks_msec()
	if (cur_tick - tick) >= 1000 and not is_dead:
		tick = cur_tick
		if is_in_group("player1"):
			PlayerState.player_score_increase_by_amount(score_per_second)
			$ExtractionAnim.play("PlayerCoin")
		elif is_in_group("enemy"):
			PlayerState.enemy_score_increase_by_amount(score_per_second)
			$ExtractionAnim.play("EnemyCoin")
