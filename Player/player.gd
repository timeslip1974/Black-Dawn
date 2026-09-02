extends Node3D

var direction=1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Forward"):
		match direction:
			1:
				position+=Vector3(0,0,-1)
			2:
				position+=Vector3(1,0,0)
			3:
				position+=Vector3(0,0,1)
			4:
				position+=Vector3(-1,0,0)
				
	if Input.is_action_just_pressed("RotateL"):
		direction-=1
		if direction==0:direction=4
		self.rotate_y(deg_to_rad(90))
	if Input.is_action_just_pressed("RotateR"):
		direction+=1
		if direction==5:direction=1
		self.rotate_y(deg_to_rad(-90))
