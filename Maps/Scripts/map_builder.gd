extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_load()

func map_load():
	Global.player=$Player
	Global.map=$TileMapLayer
	var data=0
	var filename="res://Maps/test"
	var file_as_text
	var map
	
	var packed_scene = load(filename+".tscn") as PackedScene
	
	if packed_scene:
		print("GRIDMAP")
		var gridmap = packed_scene.instantiate()
		self.add_child(gridmap)
	
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
				if tile==3:
					print(w,h)
					$TileMapLayer.set_cell(Vector2(w,h),0,Vector2(0,0))
					$Player.position=Vector3(w,0,h)+Vector3(0.5,0,0.5)
					Global.player.pos=Vector2(w,h)
				count+=1
