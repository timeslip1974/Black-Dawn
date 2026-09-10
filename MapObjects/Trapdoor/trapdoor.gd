extends Node3D

var open=false
var grid_pos


func _ready() -> void:
	grid_pos=Vector2i(position.x/2,position.z/2)

func activate():
	if open==false:
		$AnimationPlayer.play("open")
	else:
		$AnimationPlayer.play("close")
	open=!open
