extends Spatial


export (PackedScene) var crystal_cluster : PackedScene
export (int) var cluster_chance : int = 1000

onready var rng := RandomNumberGenerator.new()


func shake_noise():
	rng.randomize()

func generate_cell(point: Vector3):
	if rng.randi_range(0, cluster_chance) == 0:
		var cluster := crystal_cluster.instance()
		cluster.translation = point;
		cluster.rotate(Vector3.UP, rng.randf_range(0, 2*PI))
		add_child(cluster)
