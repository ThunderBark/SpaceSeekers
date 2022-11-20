class_name EnemyCraftController
extends Node

onready var craft : CraftController = get_child(0)
onready var attention_area : Area = craft.get_node("AttentionArea")

export (int) var health: int = 30

var rng = RandomNumberGenerator.new()

var speed : float = 100.0


func _ready():
	craft.connect("took_damage", self, "craft_took_damage")


func craft_took_damage(amount):
	print("Enemy took damage")
	health -= amount
	if health <= 0:
		die()


func _physics_process(delta):
	if !attention_area.get_overlapping_bodies().empty():
		var target_body_pos : Vector3 = attention_area.get_overlapping_bodies()[0].translation
		if craft is CraftController:
			craft.dir = craft.translation.direction_to(target_body_pos)
			craft.point_to_look = target_body_pos

func die():
	set_physics_process(false)
	craft.die()
