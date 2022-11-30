# Scene with an OptionButton to select the resolution from a list of options
extends Control

# Emitted when the selected resolution changes.
signal resolution_changed(new_resolution)

# We store a reference to the OptionButton to get the selected option later
onready var option_button: OptionButton = $OptionButton


func _update_selected_item(text: String) -> void:
	# The resolution options are written in the form "XRESxYRES".
	# Using `split_floats` we get an array with both values as floats.
	var values := text.split_floats("x")
	# Emit a signal for informing the newly selected resolution
	emit_signal("resolution_changed", Vector2(values[0], values[1]))


func _on_OptionButton_item_selected(_index: int) -> void:
	# Call the `_update_selected_item` function when the user selects
	# a new item in the `OptionButton`
	_update_selected_item(option_button.text)
