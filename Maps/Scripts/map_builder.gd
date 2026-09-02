extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_load()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func map_load():
	var data=0
	var filename="res://Maps/test.json"
	var file_as_text
	var map
	file_as_text=FileAccess.get_file_as_string(filename)
	map=JSON.parse_string(file_as_text)
	if map.layers[data].has("data"):

		var count=0
		for h in range (0,map.layers[data].height):
			for w in range (0,map.layers[data].width):
				var tile=int(map.layers[data].data[count])
				var mappos=Vector2i()
				mappos.y=int(tile/32)
				mappos.x=int(tile-(mappos.y*32))
				
				$TileMapLayer.set_cell(Vector2(w,h),0,mappos)
				if tile==2:
					$GridMap.set_cell_item(Vector3(w,0,h),1,0)
				if tile==3:
					$Player.position=Vector3(w,0,h)+Vector3(-.5,0,-.5)
				count+=1
