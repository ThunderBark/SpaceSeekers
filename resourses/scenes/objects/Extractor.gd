class_name Extractor
extends StaticBody

export(Texture) var enemy_health_bar_text: Texture
export(int) var max_health: int = 1000
export(int) var score_per_second: int = 10

onready var tick: int = Time.get_ticks_msec()
onready var hp_bar: TextureProgress = $ExtractorMesh/Healthbar3D/Viewport/HPBar
onready var coin_animation: AnimationPlayer = $ExtractionAnim
onready var animation: AnimationPlayer = $AnimationPlayer
onready var hangar: MeshInstance = $ExtractorMesh/hangar_roundB
onready var sattelite_dish: MeshInstance = $ExtractorMesh/satelliteDish

var crystal: Crystal
var health: int = max_health
var is_dead: bool = false


func _ready():
	animation.play("Construction")


func take_damage(damage_amount, shooter: Spatial):
	if is_in_group("enemy") and shooter and shooter.is_in_group("enemy"):
		return
	if is_in_group("player") and shooter and shooter.is_in_group("player"):
		return
	
	health -= damage_amount

	hp_bar.max_value = max_health
	hp_bar.value = health
	hp_bar.visible = true

	if health <= 0 and !is_dead:
		hp_bar.visible = false
		is_dead = true
		if is_in_group("enemy"):
			PlayerState.player_score_increase_by_amount(50)
		elif is_in_group("player"):
			PlayerState.enemy_score_increase_by_amount(50)
		animation.play("Explosions")
		hp_bar.visible = false
		crystal.is_vacant = true


func set_team(material: Material, group: String):
	hangar.set_surface_material(0, material)
	sattelite_dish.set_surface_material(4, material)
	add_to_group(group)
	if group in "enemy":
		hp_bar.texture_progress = enemy_health_bar_text


func _process(delta):
	# Add score to corresponding player
	var cur_tick: int = Time.get_ticks_msec()
	if (cur_tick - tick) >= 1000 and not is_dead:
		tick = cur_tick
		if is_in_group("player"):
			PlayerState.player_score_increase_by_amount(score_per_second)
			coin_animation.play("PlayerCoin")
		elif is_in_group("enemy"):
			PlayerState.enemy_score_increase_by_amount(score_per_second)
			coin_animation.play("EnemyCoin")
