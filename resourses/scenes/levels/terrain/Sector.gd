tool
extends Spatial


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


func camera_entered(camera):
	visible = true


func camera_exited(camera):
	visible = false
