extends ReferenceRect

onready var air_mode_button: TextureButton = $ModeSetButtons/Air
onready var build_mode_button: TextureButton = $ModeSetButtons/Build

signal player_changed_mode(new_mode)

func _ready():
	PlayerState.connect("player_selection_state_changed", self, "mode_selected")
	connect("player_changed_mode", PlayerState, "player_changed_mode")


func mode_selected(mode: int):
	print("mode_selected: " + String(mode))
	air_mode_button.pressed = false
	build_mode_button.pressed = false
	match mode:
		PlayerState.PLAYER_FIRING_BULLETS:
			air_mode_button.pressed = true
		PlayerState.PLAYER_BUILDING:
			build_mode_button.pressed = true


func _on_Build_button_down():
	mode_selected(PlayerState.PLAYER_BUILDING)
	emit_signal("player_changed_mode", PlayerState.PLAYER_BUILDING)


func _on_Air_button_down():
	mode_selected(PlayerState.PLAYER_FIRING_BULLETS)
	emit_signal("player_changed_mode", PlayerState.PLAYER_FIRING_BULLETS)


func _on_Build_button_up():
	mode_selected(PlayerState.PLAYER_BUILDING)
	emit_signal("player_changed_mode", PlayerState.PLAYER_BUILDING)


func _on_Air_button_up():
	mode_selected(PlayerState.PLAYER_FIRING_BULLETS)
	emit_signal("player_changed_mode", PlayerState.PLAYER_FIRING_BULLETS)
