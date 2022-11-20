# User interface that allows the player to select game settings.
# To see how we update the actual window and rendering settings, see
# `Main.gd`.
extends Control

# Emitted when the user presses the "apply" button.
signal apply_button_pressed(settings)

# We store the selected settings in a dictionary
var _settings := {resolution = Vector2(640, 480), fullscreen = false, vsync = false}


func _ready():
	connect("apply_button_pressed", Settings, "update_settings")
	# Get current settings

# Store the resolution selected by the user. As this function is connected
# to the `resolution_changed` signal, this will be executed any time the
# users chooses a new resolution
func _on_UIResolutionSelector_resolution_changed(new_resolution: Vector2) -> void:
	_settings.resolution = new_resolution


# Store the fullscreen setting. This will be called any time the users toggles
# the UIFullScreenCheckbox
func _on_UIFullscreenCheckbox_toggled(is_button_pressed: bool) -> void:
	_settings.fullscreen = is_button_pressed


# Store the vsync seting. This will be called any time the users toggles
# the UIVSyncCheckbox
func _on_UIVsyncCheckbox_toggled(is_button_pressed: bool) -> void:
	_settings.vsync = is_button_pressed


func _on_ApplyButton_button_up():
	# Send the last selected settings with the signal
	emit_signal("apply_button_pressed", _settings)
