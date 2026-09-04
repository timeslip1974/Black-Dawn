extends Node3D

var filename="res://Maps/test"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_load()



func map_load():
	Global.map=$TileMapLayer
	var data=0
	
	var file_as_text
	var map
	file_as_text=FileAccess.get_file_as_string(filename+".json")
	map=JSON.parse_string(file_as_text)
	if map.layers[data].has("data"):
		

		var count=0
		for h in range (0,map.layers[data].height):
			for w in range (0,map.layers[data].width):
				$TileMapLayer.set_cell(Vector2(w,h),0,Vector2i(0,0))
				var tile=int(map.layers[data].data[count])
				var mappos=Vector2i()
				mappos.y=int(tile/32)
				mappos.x=int(tile-(mappos.y*32))-1


				if tile>0:$TileMapLayer.set_cell(Vector2(w,h),0,mappos)
				if tile==2:
					$GridMap.set_cell_item(Vector3(w,0,h),1,0)
				if tile==3:
					print(w,h)
					$TileMapLayer.set_cell(Vector2(w,h),0,Vector2(0,0))
				count+=1
	save_gridmap_to_scene()
func save_gridmap_to_scene() -> void:
	# 1. Create a new PackedScene instance
	var packed_scene = PackedScene.new()
	
	# 2. Pack the GridMap node into the PackedScene
	# Note: If the GridMap has child nodes you want to save, 
	# you must set their 'owner' to gridmap_node before packing.
	var result = packed_scene.pack($GridMap)
	
	if result == OK:
		# 3. Save the PackedScene resource to the disk
		var save_error = ResourceSaver.save(packed_scene, filename+".tscn")
		
		if save_error == OK:
			print("GridMap successfully saved to: ", filename+".tscn")
		else:
			push_error("Failed to save the scene file. Error code: ", save_error)
	else:
		push_error("Failed to pack the GridMap node. Error code: ")
