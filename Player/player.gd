extends Node3D

const MOVESPEED=0.25

var direction=1
var moving
var tween
var pos:Vector2i
var oldpos:Vector2i
var pos_map_data:Vector2i

func _ready() -> void:
	await get_tree().process_frame
	update_mappos()

func set_player(mappos) -> void:
	pos=mappos
	position=Vector3(mappos.x*2,.5,mappos.y*2)+Vector3(1,0,1)
	rotation=Vector3(0,0,0)
	print("playerSet")

func _process(delta: float):
	check_input()
	
func check_input():
	if tween is Tween and tween.is_running():
		return
	
	if Input.is_action_just_pressed("Forward"):
		move(1)
	if Input.is_action_just_pressed("Back"):
		move(2)
	if Input.is_action_just_pressed("Left"):
		move(3)
	if Input.is_action_just_pressed("Right"):
		move(4)
	if Input.is_action_just_pressed("RotateL"):
		RotL()
	if Input.is_action_just_pressed("RotateR"):
		RotR()
		
func move(dir):
	if collision_check(dir):
		match dir:
			1: Forward()
			2: Back()
			3: Left()
			4: Right()

func collision_check(dir):
	var nextpos
	match dir:
		1:
			nextpos=self.position/2 + Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
		2:
			nextpos=self.position/2 + Vector3.BACK.rotated(Vector3.UP, rotation.y)
		3:
			nextpos=self.position/2 + Vector3.LEFT.rotated(Vector3.UP, rotation.y)
		4:
			nextpos=self.position/2 + Vector3.RIGHT.rotated(Vector3.UP, rotation.y)
	#nextpos-=Vector3(.4,0,.4)
	
	if Global.map.get_cell_atlas_coords(Vector2i(nextpos.x,nextpos.z))!=Vector2i(-1,-1):
		if Global.map.get_cell_tile_data(Vector2i(nextpos.x,nextpos.z)).get_custom_data("walkable") == true:
			oldpos=pos
			pos=Vector2i(nextpos.x,nextpos.z)
			return true
		else:
			return false
	else:return false
	
func Forward():
	update_mappos()
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + Vector3.FORWARD.rotated(Vector3.UP, rotation.y) *2, MOVESPEED)
func Back():
	update_mappos()
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + Vector3.BACK.rotated(Vector3.UP, rotation.y)*2 , MOVESPEED)
func Left():
	update_mappos()
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + Vector3.LEFT.rotated(Vector3.UP, rotation.y)*2 , MOVESPEED)
func Right():
	update_mappos()
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + Vector3.RIGHT.rotated(Vector3.UP, rotation.y)*2, MOVESPEED)
func RotL():
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var target_rotation = rotation.y + (PI / 2.0)
	tween.tween_property(self, "rotation:y", target_rotation, MOVESPEED)	
	tween.tween_callback(snap_rotation)
	direction=wrapi(direction - 1, 1, 5)
func RotR():
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var target_rotation = rotation.y - (PI / 2.0)
	tween.tween_property(self, "rotation:y", target_rotation, MOVESPEED)	
	tween.tween_callback(snap_rotation)
	direction=wrapi(direction + 1, 1, 5)

	
func snap_rotation():
	# Eliminates minor floating-point inaccuracies from the tween
	rotation.y = snappedf(rotation.y, PI / 2.0)


func update_mappos() -> void:
	Global.map.set_cell(oldpos,0,pos_map_data)
	pos_map_data=Global.map.get_cell_atlas_coords(pos)
	Global.map.set_cell(pos,0,Vector2i(2,0))
