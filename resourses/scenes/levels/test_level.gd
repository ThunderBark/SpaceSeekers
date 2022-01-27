extends Spatial


func _process(delta):
	for node in get_tree().get_nodes_in_group("trash").slice(-10,-1):
		node.free()
