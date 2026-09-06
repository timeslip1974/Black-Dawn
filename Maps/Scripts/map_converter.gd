extends Node3D

# 4-Bit Cardinal weights representing OPEN PATHS in your 2D TileMap
const N = 1  # 0001
const E = 2  # 0010
const S = 4  # 0100
const W = 8  # 1000

# LOOKUP MATRIX: Testing ONLY your 3-way open path configurations (Tiles 1-4)
const WALLS = {
	# --- THREE-WAY T-JUNCTIONS (TILES 1 TO 4) ---
	7:  4,      # Open North + East + South -> ID 4 (04-NES)
	11: 3,      # Open North + East + West  -> ID 3 (03-NEW)
	13: 2,      # Open North + South + West -> ID 2 (02-NSW)
	14: 1,      # Open East + South + West  -> ID 1 (01-ESW)
	
	# --- TEMPORARY FALLBACKS ---
	# Everything else outputs ID 0 so we can isolate exactly what tiles 1-4 are doing
	0:  0,
	1:  0, 2: 0, 4: 0, 8: 0,   # Dead ends -> solid block fallback
	5:  0, 10: 0,              # Straights -> solid block fallback
	3:  0, 9: 0, 6: 0, 12: 0,  # Corners -> solid block fallback
	15: -1                     # 4-Way Crossroad -> Clear space
}

const GRAY_FLOOR_ATLAS_COORDS = Vector2i(0, 0)

@export var map_w: int = 40
@export var map_h: int = 40

var map: TileMapLayer
var gridmap: GridMap

func _ready() -> void:
	map = $TileMapLayer
	gridmap = $GridMap
	gridmap.clear() 
	map_load()

func map_load() -> void:
	for h in range(0, map_h):
		for w in range(0, map_w):
			var current_coord = Vector2i(w, h)
			var tile = map.get_cell_atlas_coords(current_coord)
			
			if tile == GRAY_FLOOR_ATLAS_COORDS:
				calculate_and_place_3d_wall(current_coord)
				
	overwrite_current_scene()

func calculate_and_place_3d_wall(pos: Vector2i) -> void:
	var mask = 0
	
	if map.get_cell_atlas_coords(pos + Vector2i(0, -1)) == GRAY_FLOOR_ATLAS_COORDS: mask |= N
	if map.get_cell_atlas_coords(pos + Vector2i(1, 0))  == GRAY_FLOOR_ATLAS_COORDS: mask |= E
	if map.get_cell_atlas_coords(pos + Vector2i(0, 1))  == GRAY_FLOOR_ATLAS_COORDS: mask |= S
	if map.get_cell_atlas_coords(pos + Vector2i(-1, 0)) == GRAY_FLOOR_ATLAS_COORDS: mask |= W

	if WALLS.has(mask):
		var target_mesh_id = WALLS[mask]
		if target_mesh_id == -1:
			gridmap.set_cell_item(Vector3i(pos.x, 0, pos.y), GridMap.INVALID_CELL_ITEM)
		else:
			gridmap.set_cell_item(Vector3i(pos.x, 0, pos.y), target_mesh_id, 0)
	else:
		gridmap.set_cell_item(Vector3i(pos.x, 0, pos.y), 0, 0)

func overwrite_current_scene() -> void:
	_set_owner_recursive(self, self)
	var packed_scene = PackedScene.new()
	if packed_scene.pack(self) == OK:
		ResourceSaver.save(packed_scene, scene_file_path)
		print("🎉 Tiles 1-4 diagnostic pass generated successfully!")

func _set_owner_recursive(node: Node, root_node: Node) -> void:
	if node != root_node:
		node.owner = root_node
	for child in node.get_children():
		_set_owner_recursive(child, root_node)
