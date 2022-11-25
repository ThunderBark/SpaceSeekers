extends Node


export (PackedScene) var player_controller: PackedScene
export (PackedScene) var enemy_controller: PackedScene
export (int) var initial_funds: int = 400

var is_loading: bool = true
var last_progress: int = 0

func _ready():
	get_tree().paused = true
	PlayerState.master_node = self
	PlayerState.player_mode = PlayerState.PLAYER_FIRING_BULLETS
	PlayerState.player_score = initial_funds
	PlayerState.enemy_score = initial_funds
	$MapMaster.connect("sector_load_pct", self, "update_loading_progress")


func _input(event):
	if !event.is_action_type():
		return
	if last_progress == 100 and is_loading == true:
		$LoadingScreen.visible = false
		get_tree().paused = false
		is_loading = false



func update_loading_progress(progress: int):
	$LoadingScreen/LoadingProgress.max_value = 100
	$LoadingScreen/LoadingProgress.value = progress
	last_progress = progress
	if (progress == 100):
		$LoadingScreen/PressAnyKey.visible = true


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
