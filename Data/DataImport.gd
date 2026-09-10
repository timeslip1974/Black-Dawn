extends Node
var example_dict = {}
var no_of_items=79
var new_export=true
@onready var mon_list=preload("res://Data/mon_list.tres")

func _ready():
	OS.request_permissions() 
	import_resources_data()

func import_resources_data():
	mon_list.Slots.clear()
	var file = FileAccess.open("res://Data/Enemies/enemy_stats.csv", FileAccess.READ)
	var c=0
	
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
