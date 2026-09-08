@tool # 👈 Keeps the visual lines drawing live in the editor
extends Node3D

const DOOR=preload("res://MapObjects/door.tscn")
const MON1=preload("res://Monsters/Monster1/monster1.tscn")
const PILLAR=preload("res://MapObjects/pillar.tscn")
const SWITCH=preload("res://MapObjects/switch.tscn")

# 4-Bit Cardinal weights representing OPEN PATHS in your 2D TileMap
const N = 1  # 0001
const E = 2  # 0010
const S = 4  # 0100
const W = 8  # 1000

# 1-to-1 Explicit asset lookup matching your exact architecture specifications
const WALLS = {
	# Mask value (Bit Sum of open paths): MeshLib ID -> Asset Name
	0:  -1,      # Isolated tile (No open paths)  -> ID 0: 00-NONE
	15: -1,     # 4-Way Crossroad (Open all sides) -> Clear cell space
	
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

@export var map_w: int = 40
@export var map_h: int = 40

# --- RESTORED TO ARRAY SETUP WITH DRAW TRIGGER ---
@export var level_actions: Array[TileAction] = []:
	set(val):
		level_actions = val
		var layer = get_node_or_null("TileMapLayer")
		if layer:
			layer.queue_redraw()

var map: TileMapLayer
var gridmap: GridMap

func _ready() -> void:
	map = $TileMapLayer
	gridmap = $GridMap
	
	# --- FIX: Only assign to Global when the game is actually running ---
	if not Engine.is_editor_hint():
		Global.map = $TileMapLayer
		
	# Connect the drawing signal so the TileMapLayer handles the rendering
	if Engine.is_editor_hint() and map:
		if not map.draw.is_connected(_on_tilemap_draw):
			map.draw.connect(_on_tilemap_draw)
	
	# Only execute full generation and bakes when playing the actual game
	if not Engine.is_editor_hint():
		gridmap.clear() 
		$RoofFloors.clear()
		for child in $Elements.get_children():
			child.free()
		map_load()

func map_load() -> void:
	$Elements.owner = self
	
	for h in range(0, map_h):
		for w in range(0, map_w):
			var current_coord = Vector2i(w, h)
			var tile = map.get_cell_atlas_coords(current_coord)
			
			if tile == Vector2i(3, 0): # Door
				var door = DOOR.instantiate()
				door.name = "Door_" + str(w) + "_" + str(h)
				$Elements.add_child(door)
				door.position = Vector3(w * 2, 1, h * 2) - Vector3(-1, 0, -1)
				
				door.add_to_group("activatables")
				door.setup(Vector2i(w,h))
				door.owner = self 
			
			if tile == Vector2i(0, 1): # Monster
				var t = MON1.instantiate()
				t.name = "mon1_" + str(w) + "_" + str(h)
				$Elements.add_child(t)
				t.position = Vector3(w * 2, 1, h * 2) - Vector3(-1, 0, -1)
				
				t.add_to_group("activatables")
				if t.has_method("setup"):
					t.setup(Vector2i(w,h))
				t.owner = self 
				
			if tile == Vector2i(5, 0): # Pillar
				var t = PILLAR.instantiate()
				t.name = "pillar_" + str(w) + "_" + str(h)
				$Elements.add_child(t)
				t.position = Vector3(w * 2, 1, h * 2) - Vector3(-1, 0, -1)
				
				t.add_to_group("activatables")
				if t.has_method("setup"):
					t.setup(Vector2i(w,h))
				t.owner = self 
			if tile == Vector2i(1, 0): # Switch
				var t = SWITCH.instantiate()
				t.name = "switch_" + str(w) + "_" + str(h)
				$Elements.add_child(t)
				t.position = Vector3(w * 2, 1, h * 2) - Vector3(-1, 0, -1)
				t.setup(Vector2i(w,h))
				t.add_to_group("activatables")
				if t.has_method("setup"):
					t.setup(Vector2i(w,h))
				t.owner = self 
			
			if tile != Vector2i(-1, -1):
				calculate_and_place_3d_wall(current_coord)
				
	overwrite_current_scene()


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
			if randi_range(0,8)==1:
				if randi_range(0,1)==1:target_mesh_id+=15
				else:target_mesh_id+=30
			gridmap.set_cell_item(Vector3i(pos.x, 0, pos.y), target_mesh_id, 0)
	$RoofFloors.set_cell_item(Vector3i(pos.x, 0, pos.y), randi_range(0,2), 0)

func overwrite_current_scene() -> void:
	$GridMap.owner = self
	$RoofFloors.owner = self
	
	# --- ADD THIS LINE TO SECURE THE ARRAY ---
	# This forces the engine to remember the resource modifications you did in the inspector
	for action in level_actions:
		if action: action.changed.emit() 
	
	var packed_scene = PackedScene.new()
	if packed_scene.pack(self) == OK:
		ResourceSaver.save(packed_scene, scene_file_path)
		print("🎉 Clean open corridors, doors, and action maps generated successfully!")


func _process(_delta: float) -> void:
	if Engine.is_editor_hint() and is_instance_valid(map):
		map.queue_redraw()

# ==========================================
#      VISUAL ARRAY DRAWING ENGINE      
# ==========================================

func _on_tilemap_draw() -> void:
	if not Engine.is_editor_hint() or not map or not map.tile_set:
		return

	var cell_size = map.tile_set.tile_size
	
	# Safe lookup for the engine's built-in default font
	var control_node = Control.new()
	var default_font = control_node.get_theme_default_font()
	control_node.free() 
	
	var font_size = 18 # Made slightly larger to stand out on the line
	
	# Track 'action_index' to match the main Level Actions array positions (= 0, = 1, etc.)
	for action_index in range(level_actions.size()):
		var action = level_actions[action_index]
		if not action is TileAction: continue
		
		var trigger_center = map.map_to_local(action.trigger_coord)
		map.draw_circle(trigger_center, cell_size.x * 0.25, Color.YELLOW)
		
		var targets = action.get("target_coords")
		if targets and targets is Array:
			for target in targets:
				if target is Vector2i:
					var target_center = map.map_to_local(target)
					
					# 1. Draw the vector connection route path line
					map.draw_line(trigger_center, target_center, Color.GREEN, 4.0)
					map.draw_circle(target_center, cell_size.x * 0.15, Color.RED)
					
					# 2. Calculate the exact midpoint of the line to place the number
					var line_midpoint = trigger_center.lerp(target_center, 0.5)
					
					# Convert the main level_actions index to text
					var label_text = str(action_index)
					
					# Center the text over the calculated line midpoint
					# (Offsetting upward slightly by half font size so it sits balanced right on top of the line)
					var text_pos = line_midpoint + Vector2(-6, -4)
					
					# 3. Draw a tiny dark shadow behind the text so it's readable over the green lines
					map.draw_string(
						default_font,
						text_pos + Vector2(1, 1),
						label_text,
						HORIZONTAL_ALIGNMENT_LEFT,
						-1,
						font_size,
						Color.BLACK
					)
					
					# 4. Render the white level action index value directly on the line
					map.draw_string(
						default_font,
						text_pos,
						label_text,
						HORIZONTAL_ALIGNMENT_LEFT,
						-1,
						font_size,
						Color.WHITE
					)
