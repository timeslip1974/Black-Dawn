@tool # 👈 Keeps the visual lines drawing live in the editor
extends Node3D

const DOOR = preload("res://MapObjects/Door/door.tscn")
const MON = preload("res://Monsters/monster.tscn")
const PILLAR = preload("res://MapObjects/Pillar/pillar.tscn")
const TUBE = preload("res://MapObjects/Tube/pillar_2.tscn")
const SWITCH = preload("res://MapObjects/Switch/switch.tscn")
const SPINLIGHT = preload("res://MapObjects/SpinningLight/spinning_light.tscn")
const TRAPDOOR = preload("res://MapObjects/Trapdoor/trapdoor.tscn")
const FLOORSWITCH = preload("res://MapObjects/FloorSwitch/floor_switch.tscn")
const SHELF = preload("res://MapObjects/Shelf/shelf.tscn")
const FAN = preload("res://MapObjects/Fan/fan.tscn")
const TRICKWALL = preload("res://MapObjects/TrickWall/trick_wall.tscn")
const HIDDENSWITCH = preload("res://MapObjects/HiddenSwitch/hiddenswitch.tscn")
const TELEPORTER = preload("res://MapObjects/Teleporter/teleporter.tscn")

const TILE_SCENE_MAP: Dictionary = {
	Vector2i(3, 0): {"scene": DOOR, "prefix": "Door_"},
	Vector2i(7, 0): {"scene": SPINLIGHT, "prefix": "spinlight1_"},
	Vector2i(9, 0): {"scene": FLOORSWITCH, "prefix": "floorswitch_","setup_val": 1},
	Vector2i(10, 0): {"scene": FLOORSWITCH, "prefix": "floorswitch_","setup_val": 2},
	Vector2i(11, 0): {"scene": FLOORSWITCH, "prefix": "floorswitch_","setup_val": 3},
	Vector2i(12, 0): {"scene": FLOORSWITCH, "prefix": "floorswitch_","setup_val": 4},
	Vector2i(8, 0): {"scene": TRAPDOOR, "prefix": "trap1_"},
	Vector2i(13, 0): {"scene": TRAPDOOR, "prefix": "trap1_"},
	Vector2i(0, 1): {"scene": MON, "prefix": "mon1_"},
	Vector2i(1, 0): {"scene": SWITCH, "prefix": "switch_"},
	Vector2i(5, 0): {"scene": PILLAR, "prefix": "switch_"},
	Vector2i(14, 0): {"scene": SHELF, "prefix": "shelf_"},
	Vector2i(15, 0): {"scene": FAN, "prefix": "fan_"},
	Vector2i(16, 0): {"scene": TRICKWALL, "prefix": "trickwall_"},
	Vector2i(17, 0): {"scene": HIDDENSWITCH, "prefix": "hiddenSwitch_"},
	Vector2i(18, 0): {"scene": TELEPORTER, "prefix": "Teleporter_"},
}

# 4-Bit Cardinal weights representing OPEN PATHS in your 2D TileMap
const N = 1  # 0001
const E = 2  # 0010
const S = 4  # 0100
const W = 8  # 1000

# 1-to-1 Explicit asset lookup matching your exact architecture specifications
const WALLS = {
	0:  -1,     # Isolated tile
	15: 15,     # 4-Way Crossroad
	
	# --- SINGLE OPEN PATH CONNECTIONS ---
	1:  12,     # Open North only
	2:  11,     # Open East only
	4:  10,     # Open South only
	8:  9,      # Open West only
	
	# --- TWO-WAY STRAIGHT LINES ---
	5:  13,     # Open North + South
	10: 14,     # Open East + West
	
	# --- TWO-WAY CORNER PATHWAYS ---
	3:  8,      # Open North + East
	9:  7,      # Open North + West
	6:  6,      # Open East + South
	12: 5,      # Open South + West
	
	# --- THREE-WAY T-JUNCTIONS ---
	7:  4,      # Open North + East + South
	11: 3,      # Open North + East + West
	13: 2,      # Open North + South + West
	14: 1       # Open East + South + West
}

@export var map_w: int = 40
@export var map_h: int = 40

@export var level_actions: Array[TileAction] = []:
	set(val):
		level_actions = val
		var layer = get_node_or_null("TileMapLayer")
		if layer:
			layer.queue_redraw()

var map: TileMapLayer
var gridmap: GridMap
var setup_val


func _ready() -> void:
	map = get_node_or_null("TileMapLayer")
	gridmap = get_node_or_null("Map")
	
	if not Engine.is_editor_hint():
		Global.level_ready = false # FIX: Fixed syntax assignment from == to =
		Global.mon_list = preload("res://Data/mon_list.tres")
		Global.map = map
		
		if gridmap: gridmap.clear() 
		var floor_node = get_node_or_null("Floor")
		if floor_node: floor_node.clear()
		
		var elements = get_node_or_null("Elements")
		if elements:
			for child in elements.get_children():
				child.free()
		map_load()
	else:
		_connect_tilemap_draw()

func _connect_tilemap_draw() -> void:
	if map and not map.draw.is_connected(_on_tilemap_draw):
		map.draw.connect(_on_tilemap_draw)

func map_load() -> void:
	$Elements.owner = self
	floor_and_roof()
	
	for coord in map.get_used_cells():
		var tile = map.get_cell_atlas_coords(coord)
		
		if tile != Vector2i(-1, -1) or map.get_cell_tile_data(coord).get_custom_data("add_walls") == true:
			calculate_and_place_3d_wall(coord)
		
		var scene_to_instantiate: PackedScene = null
		var name_prefix := ""
		
		if tile in TILE_SCENE_MAP:
			scene_to_instantiate = TILE_SCENE_MAP[tile]["scene"]
			name_prefix = TILE_SCENE_MAP[tile]["prefix"]
			setup_val = TILE_SCENE_MAP[tile].get("setup_val", null)

		if scene_to_instantiate:
			_spawn_element(scene_to_instantiate, name_prefix, coord)

	overwrite_current_scene()

func _spawn_element(scene: PackedScene, prefix: String, coord: Vector2i) -> void:
	var instance := scene.instantiate()
	instance.name = "%s_%d_%d" % [prefix, coord.x, coord.y]
	
	$Elements.add_child(instance)
	instance.position = Vector3(coord.x * 2 + 1, 1, coord.y * 2 + 1)
	instance.owner = self
	
	if instance.has_method("setup"):
		if setup_val != null:
			instance.setup(setup_val)
		else:
			instance.setup(coord)
		
func floor_and_roof():
	for y in range(0, map_h):
		for x in range(0, map_w):
			if map.get_cell_atlas_coords(Vector2i(x,y)) != Vector2i(-1,-1):
				if map.get_cell_tile_data(Vector2i(x,y)).get_custom_data("add_floor") == true:
					$Floor.set_cell_item(Vector3i(x, 0, y), randi_range(0,2), 0)

func calculate_and_place_3d_wall(pos: Vector2i) -> void:
	var mask = 0
	var data_n = map.get_cell_tile_data(pos + Vector2i(0, -1))
	if data_n and data_n.get_custom_data("add_walls") == true: mask |= N
	var data_e = map.get_cell_tile_data(pos + Vector2i(1, 0))
	if data_e and data_e.get_custom_data("add_walls") == true: mask |= E
	var data_s = map.get_cell_tile_data(pos + Vector2i(0, 1))
	if data_s and data_s.get_custom_data("add_walls") == true: mask |= S
	var data_w = map.get_cell_tile_data(pos + Vector2i(-1, 0))
	if data_w and data_w.get_custom_data("add_walls") == true: mask |= W
	
	if WALLS.has(mask):
		var target_mesh_id = WALLS[mask]
		if target_mesh_id != -1:
			$Map.set_cell_item(Vector3i(pos.x, 0, pos.y), target_mesh_id, 0)

func overwrite_current_scene() -> void:
	$Map.owner = self
	$Floor.owner = self
	
	for action in level_actions:
		if action: action.changed.emit() 
	
	var packed_scene = PackedScene.new()
	if packed_scene.pack(self) == OK:
		ResourceSaver.save(packed_scene, scene_file_path)
		print("🎉 Clean open corridors, doors, and action maps generated successfully!")

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if not map:
			map = get_node_or_null("TileMapLayer")
		if map:
			_connect_tilemap_draw()
			map.queue_redraw()

# Creates a clickable button in the Godot Inspector
@export_tool_button("Redraw Lines", "Draw") 
var redraw_button = _on_redraw_button_pressed

func _on_redraw_button_pressed() -> void:
	map = get_node_or_null("TileMapLayer")
	if map:
		_connect_tilemap_draw()
		map.queue_redraw()
		print("🎨 Redrew TileMap editor lines!")

func _on_tilemap_draw() -> void:
	if not Engine.is_editor_hint() or not map or not map.tile_set:
		return

	var cell_size = map.tile_set.tile_size
	
	# --- ADJUST FONT SIZE HERE ---
	var default_font = ThemeDB.fallback_font
	var font_size = 4 # Reduced from 18/14 down to 10 for a compact footprint
	
	for action_index in range(level_actions.size()):
		var action = level_actions[action_index]
		if not is_instance_valid(action) or not action is TileAction: 
			continue
		
		var trigger_center = map.map_to_local(action.trigger_coord)
		map.draw_circle(trigger_center, cell_size.x * 0.25, Color.YELLOW)
		
		var action_type_name = action.get_script().get_global_name()
		if action_type_name.is_empty():
			action_type_name = "TileAction"
			
		var extra_info = action.get("action_type")
		var tooltip_info = ""
		if extra_info != null:
			tooltip_info = " (%s)" % str(extra_info)

		var label_text = "[#%d] %s%s" % [action_index, action_type_name, tooltip_info]

		var targets = action.get("target_coords")
		if targets and targets is Array:
			for target in targets:
				if target is Vector2i:
					var target_center = map.map_to_local(target)
					
					map.draw_line(trigger_center, target_center, Color.GREEN, 2.0) # Thinner 2.0 line
					map.draw_circle(target_center, cell_size.x * 0.15, Color.RED)
					
					var line_midpoint = trigger_center.lerp(target_center, 0.5)
					
					# Tighter offset suited for font_size 10
					var text_pos = line_midpoint + Vector2(-12, -2)
					
					# Shadow Text
					map.draw_string(
						default_font,
						text_pos + Vector2(1, 1),
						label_text,
						HORIZONTAL_ALIGNMENT_LEFT,
						-1,
						font_size,
						Color.BLACK
					)
					
					# Main Text
					map.draw_string(
						default_font,
						text_pos,
						label_text,
						HORIZONTAL_ALIGNMENT_LEFT,
						-1,
						font_size,
						Color.YELLOW
					)
