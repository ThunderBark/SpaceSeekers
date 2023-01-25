extends KinematicBody


export (int) var player_id = 0;


func _ready():
	pass


func _process(delta):
	if (not get_tree().has_network_peer()):
		return
	
	if not (((player_id == 1) and (get_tree().get_network_unique_id() == player_id)) or
		   ((player_id != 1) and (get_tree().get_network_unique_id() > 1))):
		return
	
	if Input.is_action_pressed("move_up"):
		move_and_collide(Vector3.FORWARD * delta)

