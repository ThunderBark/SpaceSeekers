extends Node

onready var gui_node : Control = find_node("GUI")

enum {
	PLAYER_FIRING_BULLETS,
	PLAYER_BUILDING
}
var player_state : int = PLAYER_FIRING_BULLETS

signal player_selection_state_changed(new_state)


func player_changed_mode(new_mode):
	player_state = new_mode
	self.emit_signal("player_selection_state_changed", player_state)


func _input(event):
	if (event.is_action_pressed("number_1")):
		player_state = PLAYER_FIRING_BULLETS
		self.emit_signal("player_selection_state_changed", PLAYER_FIRING_BULLETS)
	if (event.is_action_pressed("number_2")):
		player_state = PLAYER_BUILDING
		self.emit_signal("player_selection_state_changed", PLAYER_BUILDING)
