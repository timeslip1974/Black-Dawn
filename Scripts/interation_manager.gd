extends Node3D
# Array of your TileAction resources that you can configure in the Inspector
@export var action_registry: Array[TileAction] = []

# A runtime dictionary looking up target positions by their trigger positions
var interaction_map: Dictionary = {}

func _ready() -> void:
	# Build a fast coordinate lookup table
	for action in action_registry:
		interaction_map[action.trigger_coord] = action.target_coord

# Call this function when a player interacts with a button/lever
func trigger_interactable(button_coord: Vector2i) -> void:
	if interaction_map.has(button_coord):
		var target_pos = interaction_map[button_coord]
		
		# Find the door using your compiler's exact naming convention!
		var door_path = "Door_" + str(target_pos.x) + "_" + str(target_pos.y)
		var target_door = get_node_or_null(door_path)
		
		if target_door and target_door.has_method("open_door"):
			target_door.open_door()
			print("Successfully opened door at: ", target_pos)
		else:
			print("Target door node not found or missing open_door function!")
	else:
		print("This button coordinate does not trigger anything.")
