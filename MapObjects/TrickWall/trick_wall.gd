extends Node3D

var door_open=false
var grid_pos

func _ready() -> void:
	grid_pos=Vector2i(position.x/2,position.z/2)


func activate():
	if door_open==false:
		$AnimationPlayer.play("open")
	else:
		$AnimationPlayer.play("close")
	door_open=!door_open

func deactivate(t):
	print("Close Door")
	$Deactivate_timer.wait_time=t+2.0 #add the animation time
	$Deactivate_timer.start()
	

func _on_deactivate_timer_timeout() -> void:

	activate()


func change_tile():
	if door_open==true:
		Global.map.set_cell(grid_pos,0,Vector2i(1,0))
	else:
		Global.map.set_cell(grid_pos,0,Vector2i(16,0))
