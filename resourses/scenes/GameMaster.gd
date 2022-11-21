extends Node


func _on_PlayerCraftController_player_died():
	PlayerState.player_mode = PlayerState.PLAYER_DEAD
	$GUI.visible = false
	$PauseMenu/GameOverContainer/VBoxContainer/Score.text = "Space harvested: " + String(PlayerState.player_score)
	$PauseMenu/GameOverContainer.visible = true
	$PauseMenu.show_pause_menu()
	get_tree().paused = false