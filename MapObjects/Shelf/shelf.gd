extends Node3D


func setup(pos):
	print("Check shelf rot")
	if Global.map.get_cell_atlas_coords(pos+Vector2i(1,0))!=Vector2i(-1,-1):
		rotation_degrees.y = 90
	elif Global.map.get_cell_atlas_coords(pos+Vector2i(0,1))!=Vector2i(-1,-1):
		rotation_degrees.y = 180
	elif Global.map.get_cell_atlas_coords(pos+Vector2i(-1,0))!=Vector2i(-1,-1):
		rotation_degrees.y = 270
