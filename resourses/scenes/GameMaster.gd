extends Node


export (PackedScene) var player_controller: PackedScene
export (PackedScene) var enemy_controller: PackedScene
export (int) var initial_funds: int = 400
export (int) var spawn_offset: int = 10

var is_loading: bool = true
var last_progress: int = 0
var timeout: int = 180
var last_timeout_tick: int = 0

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
	$GUI.connect("player_changed_mode", self, "player_changed_mode")
	$GUI.world_end_time_changed(timeout)


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

		var settings: Dictionary = Settings.last_settings
		if settings.control_tips == true:
			$GUI/ControlsTooltip.visible = true
			$GUI/ControlsTooltip/FireTooltip.visible = true
			$GUI/ControlsTooltip/BuildTooltip.visible = false
		else:
			$GUI/ControlsTooltip.visible = false

		PlayerState.player_score_changed(PlayerState.player_score)


func _process(delta):
	if ((Time.get_ticks_msec() - last_timeout_tick >= 1000)
		and !is_loading and !get_tree().paused):
		timeout -= 1
		$GUI.world_end_time_changed(timeout)
		last_timeout_tick = Time.get_ticks_msec()
		if (timeout == 0):
			for body in get_children():
				if (body is PlayerCraftController) or (body is EnemyCraftController):
					body.queue_free()
			# Spawn clouds
			$MapMaster.spawn_storm_at_spawn()
			$Wind.stop()
			$StrongWind.play()
			if PlayerState.player_score < PlayerState.enemy_score:
				player_lost()
			else:
				player_won()


func update_loading_progress(progress: int):
	$LoadingScreen/LoadingProgress.max_value = 100
	$LoadingScreen/LoadingProgress.value = progress
	last_progress = progress
	if (progress == 100):
		$LoadingScreen/PressAnyKey.visible = true


func player_changed_mode(new_mode: int):
	var settings: Dictionary = Settings.last_settings
	if settings.control_tips == true:
		$GUI/ControlsTooltip.visible = true
		if new_mode == PlayerState.PLAYER_FIRING_BULLETS:
			$GUI/ControlsTooltip/FireTooltip.visible = true
			$GUI/ControlsTooltip/BuildTooltip.visible = false
		else:
			$GUI/ControlsTooltip/FireTooltip.visible = false
			$GUI/ControlsTooltip/BuildTooltip.visible = true
	else:
		$GUI/ControlsTooltip.visible = false


func player_lost():
	PlayerState.player_mode = PlayerState.PLAYER_DEAD
	$GUI.visible = false
	$PauseMenu/GameOverContainer/VBoxContainer/HBoxContainer/Score.text = (
		String(PlayerState.player_score)
	)
	$PauseMenu/GameOverContainer/VBoxContainer/HBoxContainer2/EnemyScore.text = (
		String(PlayerState.enemy_score)
	)
	$PauseMenu/GameOverContainer.visible = true
	$PauseMenu/GameOverContainer/VBoxContainer/LostLabel.visible = true
	$PauseMenu/GameOverContainer/VBoxContainer/WinLabel.visible = false
	$PauseMenu.show_end_menu()

func player_won():
	PlayerState.player_mode = PlayerState.PLAYER_DEAD
	$GUI.visible = false
	$PauseMenu/GameOverContainer/VBoxContainer/HBoxContainer/Score.text = (
		String(PlayerState.player_score)
	)
	$PauseMenu/GameOverContainer/VBoxContainer/HBoxContainer2/EnemyScore.text = (
		String(PlayerState.enemy_score)
	)
	$PauseMenu/GameOverContainer.visible = true
	$PauseMenu/GameOverContainer/VBoxContainer/LostLabel.visible = false
	$PauseMenu/GameOverContainer/VBoxContainer/WinLabel.visible = true
	$PauseMenu.show_end_menu()


func respawn_player():
	var player = player_controller.instance()
	add_child(player)
	player.craft.translation = player_spawn_pos

func respawn_enemy():
	var enemy = enemy_controller.instance()
	enemy.player_start_pos = player_spawn_pos
	enemy.last_extractor_position = player_spawn_pos
	add_child(enemy)
	enemy.craft.translation = enemy_spawn_pos
	enemy.world_size = world_size

