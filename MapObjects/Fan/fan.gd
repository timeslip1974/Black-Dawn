extends Node3D
var grid_pos

func _ready() -> void:
	grid_pos=Vector2i(position.x/2,position.z/2)
	await get_tree().process_frame
	setup(grid_pos)

func setup(pos):
	print("fan")
	if Global.map.get_cell_atlas_coords(pos+Vector2i(0,-1))!=Vector2i(-1,-1):
		if Global.map.get_cell_atlas_coords(pos+Vector2i(0,1))==Vector2i(-1,-1):
			print("Rot90")
			rotation_degrees.y = 90
		elif Global.map.get_cell_atlas_coords(pos+Vector2i(0,1))==Vector2i(-1,-1):
			print("Rot180")
			rotation_degrees.y = 180
		elif Global.map.get_cell_atlas_coords(pos+Vector2i(-1,0))==Vector2i(-1,-1):
			print("Rot270")
			rotation_degrees.y = 270
