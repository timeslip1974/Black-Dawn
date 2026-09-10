
extends Node3D

const MOVESPEED=0.25

var spritey
var grid_pos
var old_pos_tile_data
var tween
var DetectRange
var move_speed
var anim_machine
var monster_no
var health
var hit_chance
var ranged_attack
var damage

func _ready() -> void:
	spritey=$Sprite3D.position.y
	await get_tree().process_frame
	grid_pos=Vector2i(position.x/2,position.z/2)
	
	monster_no=Global.map.get_cell_atlas_coords(grid_pos).x
	old_pos_tile_data=Vector2i(0,0)
	DetectRange=5
	setup_vars()
	$Move_timer.wait_time=move_speed
	anim_machine=$AnimationTree.get("parameters/playback")
	anim_machine.travel("idle")

func setup_vars():
	move_speed=Global.mon_list.Slots[monster_no].speed
	health=Global.mon_list.Slots[monster_no].health
	hit_chance=Global.mon_list.Slots[monster_no].hit_chance
	ranged_attack=Global.mon_list.Slots[monster_no].ranged_attack
	damage=Global.mon_list.Slots[monster_no].damage

func _physics_process(_delta):
	var flip=randi_range(0,1000)
	if flip>995:
		FlipSprite()
		
#Shift Z access of 3D sprite to be closer to player
	var t=get_tree().get_nodes_in_group("Player")
	if Global.player.direction==3:
		$Sprite3D.transform.origin=Vector3(0,spritey,-.8)

	elif Global.player.direction==4:
		$Sprite3D.transform.origin=Vector3(.8,spritey,0)
	elif Global.player.direction==1:
		$Sprite3D.transform.origin=Vector3(0,spritey,.8)

	elif Global.player.direction==2:
		$Sprite3D.transform.origin=Vector3(-.8,spritey,0)
func move_monster():

	if tween!=null:
		if tween.is_running():
			return
	if int(grid_pos.y)>int(Global.player.pos.y):
		if !grid_pos.y-DetectRange>Global.player.pos.y:
			if !movechecker(1):
				tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "position", position + Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * 2.0, MOVESPEED)
				return
	if int(grid_pos.y)<int(Global.player.pos.y):
		if !grid_pos.y+DetectRange<Global.player.pos.y:
			if !movechecker(3):
				tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "position", position + Vector3.BACK.rotated(Vector3.UP, rotation.y) * 2.0, MOVESPEED)
				return
	if int(grid_pos.x)>int(Global.player.pos.x):
		if !grid_pos.x-DetectRange>Global.player.pos.x:
			if !movechecker(4):
				tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "position", position + Vector3.LEFT.rotated(Vector3.UP, rotation.y) * 2.0, MOVESPEED)
				return
	if int(grid_pos.x)<int(Global.player.pos.x):
		if !grid_pos.x+DetectRange<Global.player.pos.x:
			if !movechecker(2):
				tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "position", position + Vector3.RIGHT.rotated(Vector3.UP, rotation.y) *2.0, MOVESPEED)		
				return
func movechecker(MapDir):
	match MapDir:
		1:
			if Global.map.get_cell_atlas_coords(grid_pos+Vector2i(0,-1))!=Vector2i(-1,-1):
				if check_melee_attack(0,-1):
					melee_attack()
					return true
				elif Global.map.get_cell_tile_data(grid_pos+Vector2i(0,-1)).get_custom_data("walkable") == true:
					UpdateMapPos(0,-1)
					return false
				else: return true
			else: return true
		2:
			if Global.map.get_cell_atlas_coords(grid_pos+Vector2i(1,0))!=Vector2i(-1,-1):
				if check_melee_attack(1,0):
					melee_attack()
					return true
				elif Global.map.get_cell_tile_data(grid_pos+Vector2i(1,0)).get_custom_data("walkable") == true:
					UpdateMapPos(1,0)
					return false
				else: return true
			else: return true
		3:
			if Global.map.get_cell_atlas_coords(grid_pos+Vector2i(0,1))!=Vector2i(-1,-1):
				if check_melee_attack(0,1):
					melee_attack()
					return true
				elif Global.map.get_cell_tile_data(grid_pos+Vector2i(0,1)).get_custom_data("walkable") == true:
					UpdateMapPos(0,1)
					return false
				else: return true
			else: return true
		4:
			if Global.map.get_cell_atlas_coords(grid_pos+Vector2i(-1,0))!=Vector2i(-1,-1):
				if check_melee_attack(-1,0):
					melee_attack()
					return true
				elif Global.map.get_cell_tile_data(grid_pos+Vector2i(-1,0)).get_custom_data("walkable") == true:
					UpdateMapPos(-1,0)
					return false
				else: return true
			else: return true

func melee_attack():
	anim_machine.travel("attack")

func check_melee_attack(x,y):
	if Global.player.pos==grid_pos+Vector2i(x,y):
		return true
	else:return false

func UpdateMapPos(x,y):
		Global.map.set_cell(grid_pos,0,old_pos_tile_data)
		old_pos_tile_data=Global.map.get_cell_atlas_coords(grid_pos+Vector2i(x,y))
		Global.map.set_cell(Vector2i(grid_pos+Vector2i(x,y)),0,Vector2(6,0))
		grid_pos+=Vector2i(x,y)

func FlipSprite():
	$Sprite3D.flip_h=!$Sprite3D.flip_h
	
func _on_move_timer_timeout() -> void:
	move_monster()
