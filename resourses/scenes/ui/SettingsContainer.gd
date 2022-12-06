extends Popup


onready var resolution_option_btn: OptionButton = $TabContainer/DISPLAY/VBoxContainer/UIResolutionSelector/OptionButton
onready var vsync_toggle: CheckBox = $TabContainer/DISPLAY/VBoxContainer/UIVsyncCheckbox/CheckBox
onready var fullscreen_toggle: CheckBox = $TabContainer/DISPLAY/VBoxContainer/UIFullscreenCheckbox/CheckBox
onready var control_tips_toggle: CheckBox = $TabContainer/COMMON/VBoxContainer/UIControlTipCheckbox/CheckBox
onready var music_vol_slider: Slider = $TabContainer/AUDIO/VBoxContainer/HBoxContainer2/MusicVolumeSlider
onready var sfx_vol_slider: Slider = $TabContainer/AUDIO/VBoxContainer/HBoxContainer/EffectsVolumeSlider
onready var language_selector: OptionButton = $TabContainer/COMMON/VBoxContainer/UILanguageSelector/OptionButton


# Emitted when the user presses the "apply" button.
signal apply_button_pressed(settings)

# We store the selected settings in a dictionary
var _settings := {
	resolution = Vector2(1280, 720),
	fullscreen = false,
	vsync = false,
	language = "en",
	music_vol = 0.0,
	sfx_vol = 0.0
}


func _ready():
	connect("apply_button_pressed", Settings, "update_settings")

	_settings = Settings.get_settings()

	vsync_toggle.pressed = _settings.vsync
	fullscreen_toggle.pressed = _settings.fullscreen
	control_tips_toggle.pressed = _settings.control_tips
	music_vol_slider.value = _settings.music_vol
	sfx_vol_slider.value = _settings.sfx_vol
	if _settings.language in "en":
		language_selector.select(0)
	elif _settings.language in "ru":
		language_selector.select(1)
	for i in resolution_option_btn.get_item_count():
		if ((String(_settings.resolution.x) in resolution_option_btn.get_item_text(i)) and
			(String(_settings.resolution.y) in resolution_option_btn.get_item_text(i))):
			resolution_option_btn.select(i)


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


func _on_UIControlTipCheckbox_toggled(is_button_pressed: bool):
	_settings.control_tips = is_button_pressed


func _on_ApplyButton_button_up():
	# Send the last selected settings with the signal
	emit_signal("apply_button_pressed", _settings)
	popup()


func _on_OptionButton_item_selected(index:int):
	if index == 0:
		_settings.language = "en"
	elif index == 1:
		_settings.language = "ru"


func _on_MusicVolumeSlider_value_changed(value):
	_settings.music_vol = value
	if value == -30.0:
		_settings.music_vol = -80.0


func _on_EffectsVolumeSlider_value_changed(value):
	_settings.sfx_vol = value
	if value == -30.0:
		_settings.sfx_vol = -80.0

