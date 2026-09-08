extends Monster

func _ready() -> void:
	grid_pos=Vector2i(position.x/2,position.z/2)	
	spritey=$Sprite3D.position.y
	old_pos_tile_data=Vector2i(0,0)
	DetectRange=5
