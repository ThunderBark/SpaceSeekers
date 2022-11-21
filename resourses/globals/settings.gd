extends Node

onready var settings_file = "user://settings"
onready var settings_handle = File.new()


func update_settings(settings: Dictionary) -> void:
	OS.window_fullscreen = settings.fullscreen
	get_tree().set_screen_stretch(
		SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, settings.resolution
	)
	OS.set_window_size(settings.resolution)
	OS.vsync_enabled = settings.vsync

	settings_handle.open(settings_file, File.WRITE)
	settings_handle.store_var(settings, true)
	settings_handle.close()

func get_settings() -> Dictionary:
	var settings = {}

	if settings_handle.open(settings_file, File.READ) == OK:
		settings = settings_handle.get_var(true)
		settings_handle.close()
	else:
		settings = {resolution = Vector2(1280, 720), fullscreen = false, vsync = false}

	update_settings(settings)
	return settings
