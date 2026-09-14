extends Control

@export var slot_ui_scene: PackedScene = preload("res://Inventory/slot_ui.tscn")
@onready var grid_container: GridContainer = $GridContainer


func setup_slots() -> void:
	# Clear old nodes
	for child in grid_container.get_children():
		child.queue_free()
		
	var inv = Global.character_list.character[Global.active_character]
	print(inv.inventory.size())
	
	for i in range(inv.capacity):
		var slot_node = slot_ui_scene.instantiate()
		grid_container.add_child(slot_node)
		
		# 1. Break memory sharing permanently by storing unique_slot back in inv.slots[i]
		var unique_slot = inv.inventory[i].duplicate(true)
		inv.inventory[i] = unique_slot
		
		# 2. Update the UI node directly on instantiation
		slot_node.update_slot(unique_slot)


func update_inventory() -> void:
	# Used for refreshing existing UI nodes when items change mid-game
	var inv = Global.character_list.character[Global.active_character]
	var slot_nodes = grid_container.get_children()
	
	for i in range(slot_nodes.size()):
		if i < inv.inventory.size() and slot_nodes[i].has_method("update_slot"):
			slot_nodes[i].update_slot(inv.inventory[i])
