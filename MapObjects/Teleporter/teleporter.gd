extends Node3D

var grid_pos

func _ready() -> void:
	grid_pos=Vector2i(position.x/2,position.z/2)

func _on_area_3d_area_shape_entered(_area_rid: RID, _area: Area3D, _area_shape_index: int, _local_shape_index: int) -> void:
	for action in Global.level_actions:
		if action is TileAction and action.trigger_coord == grid_pos:
			Global.player.move_player(action.target_coords[0])
