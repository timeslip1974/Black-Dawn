extends Node3D

var open=false
var grid_pos


func _ready() -> void:
	await get_tree().process_frame
	grid_pos=Vector2i(position.x/2,position.z/2)
	if Global.map.get_cell_atlas_coords(grid_pos)==Vector2i(13,0):
		activate()
	
	

func activate():
	if open==false:
		$AnimationPlayer.play("open")
	else:
		$AnimationPlayer.play("close")
	death_hole()


func death_hole():
	open=!open
	if open==true:
		Global.map.set_cell(grid_pos,0,Vector2i(13,0))
	else:
		Global.map.set_cell(grid_pos,0,Vector2i(8,0))
