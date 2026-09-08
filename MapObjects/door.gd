extends Node3D

var open=false
var door_open=false

var grid_pos

func _ready() -> void:
	grid_pos=Vector2i(position.x/2,position.z/2)

func setup(pos):
	if Global.map.get_cell_atlas_coords(pos+Vector2i(-1,0))!=Vector2i(-1,-1):
		print("Rotate")
		rotation_degrees.y = 90
		
func activate():
	if door_open==false:
		$AnimationPlayer.play("open")
		Global.map.set_cell(grid_pos,0,Vector2i(4,0))
	else:
		$AnimationPlayer.play("close")
		Global.map.set_cell(grid_pos,0,Vector2i(3,0))
	door_open=!door_open
