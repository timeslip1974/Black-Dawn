extends Node3D

const MOVESPEED=0.25

var direction=1
var moving
var tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move()
	
func move():
	if tween is Tween and tween.is_running():
		return
	
	if Input.is_action_just_pressed("Forward"):
		Forward()
	if Input.is_action_just_pressed("Back"):
		Back()
	if Input.is_action_just_pressed("Left"):
		Left()
	if Input.is_action_just_pressed("Right"):
		Right()
	if Input.is_action_just_pressed("RotateL"):
		RotL()
	if Input.is_action_just_pressed("RotateR"):
		RotR()
		
		
func Forward():
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + Vector3.FORWARD.rotated(Vector3.UP, rotation.y) , MOVESPEED)
func Back():
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + Vector3.BACK.rotated(Vector3.UP, rotation.y) , MOVESPEED)
func Left():
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + Vector3.LEFT.rotated(Vector3.UP, rotation.y) , MOVESPEED)
func Right():
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + Vector3.RIGHT.rotated(Vector3.UP, rotation.y), MOVESPEED)
func RotL():
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation:y", rotation.y - (-PI / 2.0), MOVESPEED)	
func RotR():
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation:y", rotation.y - (PI / 2.0), MOVESPEED)	
