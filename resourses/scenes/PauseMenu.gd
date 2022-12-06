extends ReferenceRect


func _ready():
	visible = false


func _input(event):
	if (event.is_action_pressed("ui_cancel") and 
		(PlayerState.player_mode != PlayerState.PLAYER_DEAD) and
		!get_parent().is_loading):
		visible = !visible
		get_tree().paused = visible

func show_pause_menu():
	visible = true
	get_tree().paused = true


func show_end_menu():
	visible = true
	$ButtonsContainer/VBoxContainer/RestartButton.visible = true
	$ButtonsContainer/VBoxContainer/ReturnButton.visible = false


func _on_ReturnButton_button_up():
	if (PlayerState.player_mode != PlayerState.PLAYER_DEAD):
		visible = false
		get_tree().paused = false


func _on_MainMenuButton_button_up():
	visible = false
	get_tree().paused = false
	get_tree().change_scene("res://resourses/scenes/MainMenu.tscn")


func _on_SettingsButton_button_up():
	$SettingsContainer.popup()


func _on_QuitButton_button_up():
	get_tree().quit()


func _on_RestartButton_button_up():
	get_tree().change_scene("res://resourses/scenes/GameMaster.tscn")
