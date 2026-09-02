extends Node

# Define all hazard types here
const HAZARDS = {
	"fire": {
		"tile_id": Vector2i(10,0),
		"lifetime": 4,
		"spread_chance": 0.25,
		"spread_dirs": [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)],
		"scene":"res://Prefabs/Enviroment/acidfloor.tscn"
	},
	"acid": {
		"tile_id": Vector2i(10,0),
		"lifetime": 8,
		"spread_chance": 0.15,
		"spread_dirs": [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)],
		"scene":"res://Prefabs/Enviroment/acidfloor.tscn",
	}
}


#Level Variables
var vp
var cam_quadrant: int = 0
var camera
var hardcore=false
var health=20
var maxhealth=20
var ammo=[20,20,20]
var weapon=1
var debug=false
var soft_shadows=true
var level=1
var player=null
var player_mappos:Vector2i
var target_positions=[]
var targeted=[]
var tilemap
var gridmap
var monlist
var attacklist
var enviroment
var elements_to_update=[] # Stick in here everything that needs updating after moving
var world_builder
var tileset=1
var fog
var room_fog=[]
var rooms=[]# number,x,y,w,h
var minimap
var minimap_camera
var tiles=[] #Cut Tile Images
var map_size:Vector2i
var dungeon:Array
var dungeon_route:Array
var monsters=[]
var lights=[]
var scenery=[]
var pickups=[]
var create_map_size:Array=[5,5,5,5,5,5,5,5,5,6,6,6,6,6,7,7,7,8,8,8]
var map_path_length:Array=[5,5,5,7,7,7,7,7,9,9,9,9,11,11,11,11,13,13,15,15]
var branch_length:Array=[1,1,2,2,2,3,3,3,3,3,4,4,4,5,5,5,5,5,6,6]
var room_paths := {}   # room_id : Array[Vector2i]



func get_room_at(pos: Vector2i):
	for r in Global.rooms:
		var id = r[0]
		var rx = r[1]
		var ry = r[2]
		var rw = r[3]
		var rh = r[4]

		if pos.x >= rx and pos.x < rx + rw and pos.y >= ry and pos.y < ry + rh:
			return id

	return -1
	
func clear_children(node):
	pass
	#for c in node.get_children():
		#c.queue_free()


	
var shadow_bits:Dictionary={
	"00001000":0,#NE
	"10001000":1,#NW
	"00010000":2,#SE
	"10010000":3,#SW
	"10000000":4,#N
	"10011000":3,
	"00011000":2,

}

var wall_fills:Dictionary={
	"11110000":Vector2i(1,3),#NESW
	"00001000":Vector2i(0,4),#NE
	"00000100":Vector2i(2,4),#NW
	"00000010":Vector2i(0,2),#SE
	"00000001":Vector2i(2,2),#SW
	"10000000":Vector2i(1,4),#N
	"01000000":Vector2i(0,3),#E
	"00100000":Vector2i(1,2),#S
	"00010000":Vector2i(2,3),#W
	"10010000":Vector2i(3,2),#N W
	"11000000":Vector2i(4,2),#N E
	"00110000":Vector2i(3,3),#S W
	"01100000":Vector2i(4,3),#s e
	"10100000":Vector2i(3,4),#N S
	"01010000":Vector2i(4,4),#E W
	"00001010":Vector2i(10,4),#NW SW
	"00000101":Vector2i(13,4),#NE SE
	"00001100":Vector2i(12,4),#NE NW
	"00000011":Vector2i(11,4),#SE SW
	"00011000":Vector2i(12,3),#W NE
	"10000010":Vector2i(12,2),#N SW
	"00010010":Vector2i(15,2),#W SE
	"01110000":Vector2i(6,4),#E S W
	"10110000":Vector2i(5,3),#N S W
	"11010000":Vector2i(6,2),#N E W
	"11100000":Vector2i(7,3),#N E S
	"01000001":Vector2i(13,2),#E SW
	"10000001":Vector2i(15,3),#N SE
	"01000100":Vector2i(14,3),#E NW
	"01000101":Vector2i(9,3),#E NW SW
	"10010010":Vector2i(7,2),#N W SE
	"11000001":Vector2i(7,3),#N E SW
	"00011010":Vector2i(8,2),#W NE SE
	"00111000":Vector2i(8,3),#S W NE
	"01100100":Vector2i(7,4),#E S NW
	"00101000":Vector2i(14,2),#S NE
	"00100100":Vector2i(13,3),#S NW
	"00001110":Vector2i(31,1),#NE NW SE
	"00001001":Vector2i(8,4),#NE SW
	"00001111":Vector2i(6,3),#NE NW SE SW
	"00000110":Vector2i(9,4),#NW SE
	"00001101":Vector2i(9,3),#NE NW SW
	"10000011":Vector2i(9,2),#N SE SW
	"00101100":Vector2i(8,3),#S NE NW
	"00000111":Vector2i(11,7),#NE SE SW
	"00001011":Vector2i(12,7),#NE SE SW
}



# Active hazard instances
# Each entry: {pos, type, time_left}
var active: Array = []

func add_hazard(pos: Vector2i, hazard_type: String):
	for h in active:
		if h.pos == pos:
			return

	var data = HAZARDS[hazard_type]
	Global.tilemap.set_cell(pos,1, data.tile_id)
	var t=load(data.scene).instantiate()
	Global.enviroment.add_child(t)
	t.global_position=(pos*16)+Vector2i(8,8)
	
	active.append({
		"pos": pos,
		"type": hazard_type,
		"time_left": data.lifetime,
		"scene":t
		
	})


func update_hazards():
	for up in Global.elements_to_update:
		up.update()
	#var to_remove := []
#
	#for h in active:
		#var htype = HAZARDS[h.type]
		#h.time_left -= 1
#
		## Spread attempt
		#if randf() < htype.spread_chance:
			#try_spread(h)
#
		## Expire
		#if h.time_left <= 0:
			#to_remove.append(h)
#
	## Cleanup
	#for h in to_remove:
		#remove_tile(h.pos)
		#h.scene.queue_free()
		#active.erase(h)

func try_spread(h):
	var htype = HAZARDS[h.type]

	for dir in htype.spread_dirs:
		var new_pos = h.pos + dir

		if can_spread_to(new_pos):
			add_hazard(new_pos, h.type)

func can_spread_to(pos: Vector2i) -> bool:
	return Global.tilemap.get_cell_tile_data(pos).get_custom_data("floor")==true

func remove_tile(pos: Vector2i):
	Global.tilemap.set_cell(pos,1,Vector2i(29,0))
