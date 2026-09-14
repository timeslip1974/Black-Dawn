extends Node
var example_dict = {}

var new_export=true
@onready var mon_list=preload("res://Data/mon_list.tres")
@onready var item_list=preload("res://Data/item_list.tres")

func _ready():
	OS.request_permissions() 
	import_resources_data()

func import_resources_data():
	item_list.slots.clear()
	#for c in no_of_items:
		#item_list.Slots[c].Item=Item.new()

	var file = FileAccess.open("res://Data/Items/Items.csv", FileAccess.READ)
	var c=0
	
	while !file.eof_reached():
			var data_set = Array(file.get_csv_line())
			if file.file_exists("res://Data/Items/"+str(data_set[0])+".tres"):
				print(data_set[0])
				var res=load("res://Data/Items/"+str(data_set[0])+".tres")
				res.file_name=data_set[0]
				res.name=data_set[1]
				var parts=data_set[2].split(",")
				res.gfx_frame=Vector2i(parts[0].strip_edges().to_float(),parts[1].strip_edges().to_float())

				
				item_list.slots.insert(c,res)
				c+=1
				ResourceSaver.save(res,"res://Data/Items/"+str(data_set[0])+".tres")
			ResourceSaver.save(item_list,"res://Data/item_list.tres")
	file.close()
	
	
	
	
	mon_list.Slots.clear()
	file = FileAccess.open("res://Data/Enemies/enemy_stats.csv", FileAccess.READ)
	c=0
	
	while !file.eof_reached():
		var data_set = Array(file.get_csv_line())
		if file.file_exists("res://Data/Enemies/"+str(data_set[0])+".tres"):
			print(data_set[0])
			var res=load("res://Data/Enemies/"+str(data_set[0])+".tres")
			res.file_name=data_set[0]
			res.name=data_set[1]
			res.speed=int(data_set[2])
			res.health=int(data_set[3])
			res.hit_chance=int(data_set[4])
			if data_set[5]=="y":res.ranged_attack=true
			else:res.ranged_attack=false
			res.damage=int(data_set[6])
			res.attack_time=float(data_set[7])
			res.sprite_sheet=data_set[8]
			res.range_type=int(data_set[9])

			
			mon_list.Slots.insert(c,res)
			c+=1
			ResourceSaver.save(res,"res://Data/Enemies/"+str(data_set[0])+".tres")
		ResourceSaver.save(mon_list,"res://Data/mon_list.tres")
	file.close()
