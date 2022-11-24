extends Node


export (PackedScene) var player_controller: PackedScene
export (PackedScene) var enemy_controller: PackedScene
export (int) var initial_funds: int = 400

func _ready():
	PlayerState.master_node = self
	PlayerState.player_mode = PlayerState.PLAYER_FIRING_BULLETS
	PlayerState.player_score = initial_funds
	PlayerState.enemy_score = initial_funds


func player_lost():
	PlayerState.player_mode = PlayerState.PLAYER_DEAD
	$GUI.visible = false
	$PauseMenu/GameOverContainer/VBoxContainer/Score.text = "Space harvested: " + String(PlayerState.player_score)
	$PauseMenu/GameOverContainer.visible = true
	$PauseMenu.show_pause_menu()
	get_tree().paused = false

func player_won():
	PlayerState.player_mode = PlayerState.PLAYER_DEAD
	$GUI.visible = false
	$PauseMenu/WinContainer/VBoxContainer/Score.text = "Space harvested: " + String(PlayerState.player_score)
	$PauseMenu/WinContainer.visible = true
	$PauseMenu.show_pause_menu()
	get_tree().paused = false


func respawn_player():
	var player = player_controller.instance()
	add_child(player)
	player.craft.translation = Vector3(0.0, 3.0, 0.0)


func respawn_enemy():
	var enemy = enemy_controller.instance()
	add_child(enemy)
	enemy.craft.translation = Vector3(0.0, 3.0, 0.0)
