extends Node3D

var grid_pos
enum switch_type{PRESSURE,NORMAL}
var type


func _ready() -> void:
	grid_pos=Vector2i(position.x/2,position.z/2)
func setup(t):
	match t:
		1:
			$Switch.visible=false
			type=switch_type.PRESSURE
		2:
			$Switch.visible=false
			type=switch_type.NORMAL
		3:
			type=switch_type.PRESSURE
		4:
			type=switch_type.NORMAL


func _on_area_3d_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	Global.trigger_tile_action(grid_pos)



func _on_area_3d_area_shape_exited(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	if type==switch_type.PRESSURE:
		Global.trigger_tile_action(grid_pos)
