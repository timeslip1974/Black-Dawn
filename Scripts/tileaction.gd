extends Resource
class_name TileAction

@export var trigger_coord: Vector2i  # The coordinate of the Button / Pressure Plate
@export var target_coords: Array[Vector2i] = [] # Supports multiple targets!
@export var time:float=0.0 # If not 0 then switch is timed
