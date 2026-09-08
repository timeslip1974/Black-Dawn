class_name Monster
extends Node3D

const MOVESPEED=0.25

var spritey
var grid_pos
var old_pos_tile_data
var tween
var DetectRange
var moved=false



func _physics_process(_delta):
	var flip=randi_range(0,1000)
	if flip>985:
		FlipSprite()
		
#Shift Z access of 3D sprite to be closer to player
	var t=get_tree().get_nodes_in_group("Player")
	if Global.player.direction==3:
		$Sprite3D.transform.origin=Vector3(0,spritey,-.8)
		#$particle_node.transform.origin=Vector3(0,particle_pos.y,-.8)

	elif Global.player.direction==4:
		$Sprite3D.transform.origin=Vector3(.8,spritey,0)
		#$particle_node.transform.origin=Vector3(.8,particle_pos.y,0)
	elif Global.player.direction==1:
		$Sprite3D.transform.origin=Vector3(0,spritey,.8)
		#$particle_node.transform.origin=Vector3(0,particle_pos.y,.8)

	elif Global.player.direction==2:
		$Sprite3D.transform.origin=Vector3(-.8,spritey,0)

		#$particle_node.transform.origin=Vector3(-.8,particle_pos.y,0)
func move_monster():

	if tween!=null:
		if tween.is_running():
			return
	if int(grid_pos.y)>int(Global.player.pos.y):
		if !grid_pos.y-DetectRange>Global.player.pos.y:
			if !movechecker(1):
				tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "position", position + Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * 2.0, MOVESPEED)
				moved=true
				return
	if int(grid_pos.y)<int(Global.player.pos.y):
		if !grid_pos.y+DetectRange<Global.player.pos.y:
			if !movechecker(3):
				tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "position", position + Vector3.BACK.rotated(Vector3.UP, rotation.y) * 2.0, MOVESPEED)
				moved=true
				return
	if int(grid_pos.x)>int(Global.player.pos.x):
		if !grid_pos.x-DetectRange>Global.player.pos.x:
			if !movechecker(4):
				tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "position", position + Vector3.LEFT.rotated(Vector3.UP, rotation.y) * 2.0, MOVESPEED)
				moved=true
				return
	if int(grid_pos.x)<int(Global.player.pos.x):
		if !grid_pos.x+DetectRange<Global.player.pos.x:
			if !movechecker(2):
				tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "position", position + Vector3.RIGHT.rotated(Vector3.UP, rotation.y) *2.0, MOVESPEED)		
				moved=true
				return
func movechecker(MapDir):
	match MapDir:
		1:
			if Global.map.get_cell_tile_data(grid_pos+Vector2i(0,-1)).get_custom_data("walkable") == true:
				UpdateMapPos(0,-1)
				return false
			else: return true
		2:
			if Global.map.get_cell_tile_data(grid_pos+Vector2i(1,0)).get_custom_data("walkable") == true:
				UpdateMapPos(1,0)
				return false
			else: return true
		3:

			if Global.map.get_cell_tile_data(grid_pos+Vector2i(0,1)).get_custom_data("walkable") == true:
				UpdateMapPos(0,1)
				return false
			else: return true
		4:
			if Global.map.get_cell_tile_data(grid_pos+Vector2i(1,0)).get_custom_data("walkable") == true:
				UpdateMapPos(-1,0)
				return false
			else: return true

func UpdateMapPos(x,y):
	Global.map.set_cell(grid_pos,0,old_pos_tile_data)
	old_pos_tile_data=Global.map.get_cell_atlas_coords(grid_pos+Vector2i(x,y))
	Global.map.set_cell(Vector2i(grid_pos+Vector2i(x,y)),0,Vector2(6,0))
	grid_pos+=Vector2i(x,y)

func FlipSprite():
	$Sprite3D.flip_h=!$Sprite3D.flip_h
