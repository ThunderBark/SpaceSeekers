extends Node


export (PackedScene) var player_controller: PackedScene
export (PackedScene) var enemy_controller: PackedScene
export (int) var initial_funds: int = 400
export (int) var spawn_offset: int = 10

onready var map_master: Spatial = $MapMaster
onready var world_size: int = $MapMaster.terrain_size
onready var planet_animation: AnimatedSprite = $LoadingScreen/Control/PlanetAnimatedSprite

onready var gui: Control = $GUI
onready var controls_build_tooltip: Control = $GUI/ControlsTooltip/BuildTooltip
onready var controls_fire_tooltip: Control = $GUI/ControlsTooltip/FireTooltip
onready var controls_tooltip: Control = $GUI/ControlsTooltip

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

var is_loading: bool = true
var last_progress: int = 0
var timeout: int = 180
var last_timeout_tick: int = 0


func _ready():
	get_tree().paused = true

	PlayerState.master_node = self
	PlayerState.player_mode = PlayerState.PLAYER_FIRING_BULLETS
	PlayerState.player_score = initial_funds
	PlayerState.enemy_score = initial_funds

	map_master.connect("sector_load_pct", self, "update_loading_progress")
	PlayerState.connect("player_selection_state_changed", PlayerState, "player_changed_mode")
	gui.world_end_time_changed(timeout)

	$LoadingScreen.visible = true
	planet_animation.playing = true


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

		var settings := Settings.get_settings()

		PlayerState.player_score_changed(PlayerState.player_score)


func _process(delta):
	if ((Time.get_ticks_msec() - last_timeout_tick >= 1000)
		and !is_loading and !get_tree().paused):
		timeout -= 1
		gui.world_end_time_changed(timeout)
		last_timeout_tick = Time.get_ticks_msec()
		if (timeout == 0):
			for body in get_children():
				if (body is PlayerCraftController) or (body is EnemyCraftController):
					body.queue_free()

			# Spawn clouds
			map_master.spawn_storm_at_spawn()
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


func player_lost():
	PlayerState.player_mode = PlayerState.PLAYER_DEAD
	gui.visible = false
	$PauseMenu/GameOverContainer/VBoxContainer/HBoxContainer/Score.text = (
		String(PlayerState.player_score)
	)
	$PauseMenu/GameOverContainer/VBoxContainer/HBoxContainer2/EnemyScore.text = (
		String(PlayerState.enemy_score)
	)
	$PauseMenu/GameOverContainer.visible = true
	$PauseMenu/GameOverContainer/VBoxContainer/GameOverLabel.text = "YOU_LOSE"
	$PauseMenu/GameOverContainer/VBoxContainer/GameOverLabel.visible = true
	$PauseMenu.show_end_menu()

func player_won():
	PlayerState.player_mode = PlayerState.PLAYER_DEAD
	gui.visible = false
	$PauseMenu/GameOverContainer/VBoxContainer/HBoxContainer/Score.text = (
		String(PlayerState.player_score)
	)
	$PauseMenu/GameOverContainer/VBoxContainer/HBoxContainer2/EnemyScore.text = (
		String(PlayerState.enemy_score)
	)
	$PauseMenu/GameOverContainer.visible = true
	$PauseMenu/GameOverContainer/VBoxContainer/GameOverLabel.text = "YOU_WIN"
	$PauseMenu/GameOverContainer/VBoxContainer/GameOverLabel.visible = true
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

