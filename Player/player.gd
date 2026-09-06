extends Node3D

const MOVESPEED=0.25

var direction=1
var moving
var tween
var pos:Vector2
var oldpos:Vector2

func set_player(mappos) -> void:
	pos=mappos
	position=Vector3(mappos.x*2,0,mappos.y*2)+Vector3(1,0,1)
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
#	pos=Vector2(position.x,position.z)-Vector2(0.5,0.5)
	oldpos=pos
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
	nextpos-=Vector3(.4,0,.4)
	
	if Global.map.get_cell_atlas_coords(Vector2i(nextpos.x,nextpos.z))==Vector2i(0,0):
		pos=Vector2i(nextpos.x,nextpos.z)
		return true
	else:
		pos=oldpos
		return false
	
func Forward():
	$Timer.start()
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + Vector3.FORWARD.rotated(Vector3.UP, rotation.y) *2, MOVESPEED)
func Back():
	$Timer.start()
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + Vector3.BACK.rotated(Vector3.UP, rotation.y)*2 , MOVESPEED)
func Left():
	$Timer.start()
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + Vector3.LEFT.rotated(Vector3.UP, rotation.y)*2 , MOVESPEED)
func Right():
	$Timer.start()
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + Vector3.RIGHT.rotated(Vector3.UP, rotation.y)*2, MOVESPEED)
func RotL():
	print("ROTL")
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation:y", rotation.y - (-PI / 2.0), MOVESPEED)	
func RotR():
	print("ROTR")
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation:y", rotation.y - (PI / 2.0), MOVESPEED)	


func _on_timer_timeout() -> void:
	Global.map.set_cell(oldpos,0,Vector2i(0,0))
	Global.map.set_cell(pos,0,Vector2i(2,0))
