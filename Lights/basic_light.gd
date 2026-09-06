extends Node3D



func _ready() -> void:
	$OmniLight3D.light_color=Color.from_hsv(randf(), 1.0, 1.0)
