extends ReferenceRect


func _on_QuitButton_button_down():
	get_tree().quit()


func _on_SettingsButton_button_down():
	$SettingsContainer.visible = !$SettingsContainer.visible


func _on_PlayButton_button_down():
	get_tree().change_scene("res://resourses/scenes/GameMaster.tscn")
