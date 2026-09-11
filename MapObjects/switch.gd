extends Node3D

var grid_pos

func _ready() -> void:
	grid_pos=Vector2i(position.x/2,position.z/2)
	await get_tree().process_frame
	setup(grid_pos)

func setup(pos):
	print(Global.map.get_cell_atlas_coords(pos)+Vector2i(0,-1))
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


#Make sire to connect the Staticbody of the switch to the main switch in Signals for it to work
func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		$AnimationPlayer.play("press")
		
		# 2. Tell the Global system to trigger whatever is linked to this tile coordinate!
		Global.trigger_tile_action(grid_pos)
