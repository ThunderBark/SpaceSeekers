extends Camera


func _process(delta):
	if (current == true) and (get_tree().paused == false):
		get_tree().paused = true
