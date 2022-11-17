extends ReferenceRect

onready var air_mode_button: TextureButton = $ModeSetButtons/Air
onready var build_mode_button: TextureButton = $ModeSetButtons/Build

onready var hp_bar: TextureProgress = $HPBarContainer/HPBar
onready var score_label : Label = $ScoreContainer/Score

signal player_changed_mode(new_mode)


func _ready():
	if connect("player_changed_mode", PlayerState, "_player_changed_mode") != OK:
		get_tree().quit(1)
	if PlayerState.connect("player_hp_changed_sig", self, "_player_hp_changed") != OK:
		get_tree().quit(2)
	if PlayerState.connect("player_score_changed_sig", self, "_player_score_changed") != OK:
		get_tree().quit(3)


func _input(event):
	if event.is_action_pressed("number_1"):
		self.emit_signal("player_selection_state_changed", PlayerState.PLAYER_FIRING_BULLETS)
		_mode_selected(PlayerState.PLAYER_FIRING_BULLETS)
	if event.is_action_pressed("number_2"):
		self.emit_signal("player_selection_state_changed", PlayerState.PLAYER_BUILDING)
		_mode_selected(PlayerState.PLAYER_BUILDING)
	# if event.is_action_pressed("primary_fire_action"):
	# 	PlayerState.player_score_changed(int(score_label.text) + 10)


func _player_hp_changed(new_hp):
	hp_bar.value = new_hp


func _player_score_changed(new_score):
	score_label.text = String(new_score)


func _mode_selected(mode: int):
	air_mode_button.pressed = false
	build_mode_button.pressed = false
	match mode:
		PlayerState.PLAYER_FIRING_BULLETS:
			emit_signal("player_changed_mode", mode)
			air_mode_button.pressed = true
		PlayerState.PLAYER_BUILDING:
			emit_signal("player_changed_mode", mode)
			build_mode_button.pressed = true


func _on_Build_button_down():
	_mode_selected(PlayerState.PLAYER_BUILDING)


func _on_Air_button_down():
	_mode_selected(PlayerState.PLAYER_FIRING_BULLETS)


func _on_Build_button_up():
	_mode_selected(PlayerState.PLAYER_BUILDING)


func _on_Air_button_up():
	_mode_selected(PlayerState.PLAYER_FIRING_BULLETS)
