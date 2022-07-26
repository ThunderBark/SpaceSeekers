extends Camera

export (float) var mouse_speed = 0.2
export (float) var move_speed = 2.0
var previous_mouse_position : Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir := Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		dir += Vector3.FORWARD
	if Input.is_key_pressed(KEY_S):
		dir += Vector3.BACK
	if Input.is_key_pressed(KEY_A):
		dir += Vector3.LEFT
	if Input.is_key_pressed(KEY_D):
		dir += Vector3.RIGHT
	
	if Input.is_action_just_pressed("primary_fire_action"):
		previous_mouse_position = get_viewport().get_mouse_position()
	if Input.is_action_pressed("primary_fire_action"):
		var current_mouse_position = get_viewport().get_mouse_position()
		
		rotate_object_local(Vector3.DOWN, (current_mouse_position.x - previous_mouse_position.x) * delta * mouse_speed)
		rotate_object_local(Vector3.LEFT, (current_mouse_position.y - previous_mouse_position.y) * delta * mouse_speed)
		
		previous_mouse_position = current_mouse_position
	
	translate_object_local(dir * delta * move_speed * (2 if Input.is_key_pressed(KEY_SHIFT) else 1))
