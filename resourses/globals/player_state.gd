extends Node

onready var gui_node: Control = find_node("GUI")

enum { PLAYER_FIRING_BULLETS, PLAYER_BUILDING }
var player_mode: int = PLAYER_FIRING_BULLETS

signal player_selection_state_changed(new_state)
signal player_hp_changed_sig(new_hp)


func player_hp_changed(new_hp):
	self.emit_signal("player_hp_changed_sig", new_hp)


func _player_changed_mode(new_mode):
	player_mode = new_mode
	self.emit_signal("player_selection_state_changed", player_mode)
