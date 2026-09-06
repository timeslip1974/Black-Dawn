extends Node3D

var level="res://Maps/Test/test_map.tscn"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.player=$Player
	load_level()
	await get_tree().process_frame
	Global.map=$TileMapLayer
	place_player()
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func place_player():
	for h in range(0, 40):
		for w in range(0, 40):
			if $TileMapLayer.get_cell_atlas_coords(Vector2i(w,h))==Vector2i(2,0):
				Global.player.set_player(Vector2i(w,h))
				$TileMapLayer.set_cell(Vector2i(w,h),0,Vector2i(0,0))


func load_level() -> void:
	# 1. Safety check to make sure the file exists on the disk
	if not ResourceLoader.exists(level):
		push_error("Cannot load elements: File not found at " + level)
		return
		
	# 2. Load the scene resource file data into memory
	var packed_scene: PackedScene = load(level)
	
	# 3. Instantiate the scene invisibly in the background (not added to the tree yet)
	var temporary_root: Node = packed_scene.instantiate()
	
	# 4. Find the specific element node you want to copy (e.g., your GridMap)
	# Replace "GridMap" with the exact name of the node inside that saved file
	var saved_gridmap = temporary_root.get_node_or_null("GridMap")
	var saved_tilemap=temporary_root.get_node_or_null("TileMapLayer")
	
	if saved_gridmap:
		# 5. Detach the GridMap from the temporary background scene root
		temporary_root.remove_child(saved_gridmap)
		temporary_root.remove_child(saved_tilemap)
		
		# 6. Add it cleanly into your CURRENT active scene tree layout
		add_child(saved_gridmap)
		add_child(saved_tilemap)
		
		# Optional: Adjust its 3D position or alignment if necessary
		# saved_gridmap.global_position = Vector3.ZERO
		
		print("🎉 Successfully imported GridMap element into the active scene!")
	else:
		push_error("Could not find a node named 'GridMap' inside the saved scene file.")
		
	# 7. CRITICAL: Clean up the invisible temporary root node to prevent memory leaks
	temporary_root.queue_free()
