extends Node

enum {
	PLAYER_FIRING,
	PLAYER_BUILDING
}
var player_state : int = PLAYER_FIRING

signal player_selection_state_changed

func _input(event):
	if (event.is_action_pressed("primary_fire_action")):
		match player_state:
			PLAYER_FIRING:
				player_state = PLAYER_BUILDING
			PLAYER_BUILDING:
				player_state = PLAYER_FIRING
		print(player_state)
		self.emit_signal("player_selection_state_changed")
