extends Node

var player
var map
var mon_list
var level_actions: Array[TileAction] = []

func trigger_tile_action(action_coord: Vector2i):
	var scene=get_tree().current_scene
	var elements=scene.get_node_or_null("Elements")
	print(elements)
	# 1. Look through the actions array we cloned during load_level()
	for action in level_actions:
		if action is TileAction and action.trigger_coord == action_coord:
			for child in elements.get_children():
				if "grid_pos" in child and child.grid_pos in action.target_coords:
					if child.has_method("activate"):
						child.activate()
