extends Node


export (PackedScene) var player_controller: PackedScene
export (PackedScene) var enemy_controller: PackedScene
export (int) var initial_funds: int = 400
export (int) var spawn_offset: int = 10

var is_loading: bool = true
var last_progress: int = 0

onready var world_size: int = $MapMaster.terrain_size
onready var enemy_spawn_pos: Vector3 = Vector3(
	world_size / 2.0 - spawn_offset,
	3.0,
	world_size / 2.0 - spawn_offset
)
onready var player_spawn_pos: Vector3 = Vector3(
	-enemy_spawn_pos.x,
	3.0,
	-enemy_spawn_pos.z
)

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

		# Spawn players
		respawn_player()
		respawn_enemy()




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
	player.craft.translation = player_spawn_pos


func respawn_enemy():
	var enemy = enemy_controller.instance()
	enemy.player_start_pos = player_spawn_pos
	add_child(enemy)
	enemy.craft.translation = enemy_spawn_pos

