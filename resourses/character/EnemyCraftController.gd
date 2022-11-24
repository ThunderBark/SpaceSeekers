class_name EnemyCraftController
extends Node

export (NodePath) var grid_path: NodePath
export (SpatialMaterial) var enemy_material: SpatialMaterial
export (PackedScene) var extractor1: PackedScene
export (Vector3) var last_player_position: Vector3 = Vector3.ZERO
export (int) var max_health: int = 30
export (int) var health: int = 30

onready var extractor: Spatial
onready var craft : CraftController = $SpeederA
onready var attention_area : Area = craft.get_node("AttentionArea")
onready var grid: GridMap = get_node(grid_path)

var rng = RandomNumberGenerator.new()
var speed : float = 100.0


func _ready():
	craft.connect("took_damage", self, "craft_took_damage")
	craft.set_team(enemy_material, "enemy")


func craft_took_damage(amount):
	print("Enemy took damage")
	health -= amount
	craft.set_hp(health, max_health)
	if health <= 0:
		craft.hide_hp_bar()
		die()


func try_find_rotation(point: Vector3) -> int:
	for i in 4:
		var angle: float = i * PI / 2 + PI / 4
		if (grid.get_cell_item(
				int(round(point.x + sign(sin(angle)) * 0.5 + 0.5)),
				int(round(point.y * 2)),
				int(round(point.z + sign(cos(angle)) * 0.5 + 0.5))
			) == 0):
			if (grid.get_cell_item(
					int(round(point.x + sign(sin(angle)) * 0.5 - 0.5)),
					int(round(point.y * 2)),
					int(round(point.z + sign(cos(angle)) * 0.5 - 0.5))
				) == 0):
				if (grid.get_cell_item(
						int(round(point.x + sign(sin(angle)) * 0.5 - 0.5)),
						int(round(point.y * 2)),
						int(round(point.z + sign(cos(angle)) * 0.5 + 0.5))
					) == 0):
					if (grid.get_cell_item(
							int(round(point.x + sign(sin(angle)) * 0.5 + 0.5)),
							int(round(point.y * 2)),
							int(round(point.z + sign(cos(angle)) * 0.5 - 0.5))
						) == 0):
						return i
	return -1


func _physics_process(delta):
	for body in attention_area.get_overlapping_bodies():
		if (body is CraftController) and (body.is_in_group("player1")):
			var target_body_pos : Vector3 = body.translation
			if craft is CraftController:
				craft.dir = craft.translation.direction_to(target_body_pos)
				craft.point_to_look = target_body_pos

		if (body is Crystal) and (body.is_vacant == true) and has_enough_score_to_build():
			var rotation_y = try_find_rotation(body.global_translation)
			if rotation_y == -1:
				return
			
			extractor = extractor1.instance()
			extractor.translation = body.translation
			extractor.rotate(Vector3.UP, rotation_y * PI/2)
			extractor.crystal = body
			get_parent().add_child(extractor)
			body.is_vacant = false
			extractor.set_team(enemy_material, "enemy")
			PlayerState.enemy_buy_extractor()


func die():
	set_physics_process(false)
	craft.die()


func has_enough_score_to_build() -> bool:
	if PlayerState.enemy_score >= PlayerState.extractor_cost:
		return true
	return false


func _think():
	pass


# func get_score() -> int:
# 	Player