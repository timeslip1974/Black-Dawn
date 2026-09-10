extends Node3D

var grid_pos

func _ready() -> void:
	grid_pos=Vector2i(position.x/2,position.z/2)

func _on_area_3d_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	Global.trigger_tile_action(grid_pos)


func _on_area_3d_area_shape_exited(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	Global.trigger_tile_action(grid_pos)
