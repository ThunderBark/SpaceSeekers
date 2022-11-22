class_name EnemyCraftController
extends Node

export (SpatialMaterial) var enemy_material: SpatialMaterial
export(PackedScene) var extractor1: PackedScene
onready var extractor: Spatial

onready var craft : CraftController = get_child(0)
onready var attention_area : Area = craft.get_node("AttentionArea")

export (int) var health: int = 30

var rng = RandomNumberGenerator.new()

var speed : float = 100.0


func _ready():
	craft.add_to_group("enemy")
	craft.connect("took_damage", self, "craft_took_damage")
	craft.set_craft_material(enemy_material)


func craft_took_damage(amount):
	print("Enemy took damage")
	health -= amount
	if health <= 0:
		die()


func _physics_process(delta):
	for body in attention_area.get_overlapping_bodies():
		if (body is CraftController) and (body.is_in_group("player1")):
			var target_body_pos : Vector3 = body.translation
			if craft is CraftController:
				craft.dir = craft.translation.direction_to(target_body_pos)
				craft.point_to_look = target_body_pos
		if (body is Crystal) and (body.is_vacant == true):
			extractor = extractor1.instance()
			extractor.translation = body.translation
			extractor.crystal = body
			get_parent().add_child(extractor)
			body.is_vacant = false
			extractor.set_team(enemy_material, "enemy")

func die():
	set_physics_process(false)
	craft.die()
