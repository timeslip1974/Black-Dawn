extends Node3D

# 4-Bit Cardinal weights representing OPEN PATHS in your 2D TileMap
const N = 1  # 0001
const E = 2  # 0010
const S = 4  # 0100
const W = 8  # 1000

# 1-to-1 Explicit asset lookup matching your exact architecture specifications
const WALLS = {
	# Mask value (Bit Sum of open paths): MeshLib ID -> Asset Name
	0:  0,      # Isolated tile (No open paths)  -> ID 0: 00-NONE
	15: 15,     # 4-Way Crossroad (Open all sides) -> Clear cell space
	
	# --- SINGLE OPEN PATH CONNECTIONS (DEAD ENDS) ---
	1:  12,     # Open North only -> ID 12: 12-N
	2:  11,     # Open East only  -> ID 11: 11-E
	4:  10,     # Open South only -> ID 10: 10-S
	8:  9,      # Open West only  -> ID 9:  09-W
	
	# --- TWO-WAY STRAIGHT LINES ---
	5:  13,     # Open North + South (Vertical)   -> ID 13: 13-NS
	10: 14,     # Open East + West (Horizontal) -> ID 14: 14-EW
	
	# --- TWO-WAY CORNER PATHWAYS ---
	3:  8,      # Open North + East  -> ID 8: 08-NE
	9:  7,      # Open North + West  -> ID 7: 07-NW
	6:  6,      # Open East + South  -> ID 6: 06-ES
	12: 5,      # Open South + West  -> ID 5: 05-SW
	
	# --- THREE-WAY T-JUNCTIONS ---
	7:  4,      # Open North + East + South -> ID 4: 04-NES
	11: 3,      # Open North + East + West  -> ID 3: 03-NEW
	13: 2,      # Open North + South + West -> ID 2: 02-NSW
	14: 1       # Open East + South + West  -> ID 1: 01-ESW
}

# Explicitly target only your path tile coordinate in your 2D TileMap atlas sheet
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
			
			if tile !=Vector2i(-1,-1):
				calculate_and_place_3d_wall(current_coord)
				
	overwrite_current_scene()

func calculate_and_place_3d_wall(pos: Vector2i) -> void:
	var mask = 0
# --- SAFE NORTH CHECK ---
	var data_n = map.get_cell_tile_data(pos + Vector2i(0, -1))
	if data_n and data_n.get_custom_data("floor") == true: mask |= N
	# --- SAFE EAST CHECK ---
	var data_e = map.get_cell_tile_data(pos + Vector2i(1, 0))
	if data_e and data_e.get_custom_data("floor") == true: mask |= E
	# --- SAFE SOUTH CHECK ---
	var data_s = map.get_cell_tile_data(pos + Vector2i(0, 1))
	if data_s and data_s.get_custom_data("floor") == true: mask |= S
	# --- SAFE WEST CHECK ---
	var data_w = map.get_cell_tile_data(pos + Vector2i(-1, 0))
	if data_w and data_w.get_custom_data("floor") == true: mask |= W
	
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
		print("🎉 Clean open corridors generated successfully!")

func _set_owner_recursive(node: Node, root_node: Node) -> void:
	if node != root_node:
		node.owner = root_node
	for child in node.get_children():
		_set_owner_recursive(child, root_node)
