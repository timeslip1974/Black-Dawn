extends Control

@export var slot_ui_scene: PackedScene = preload("res://Inventory/slot_ui.tscn") # Point to your slot scene
@onready var grid_container: GridContainer = $GridContainer

# Select which party member's inventory to show (0 to 3)
@export var character_index: int = 0 

func _ready() -> void:
	Global.party_inventories=preload("res://Data/party_inventories.tres")
	setup_slots()

func setup_slots() -> void:
	# Clear existing placeholder children
	for child in grid_container.get_children():
		child.queue_free()
	var inv = Global.party_inventories.Slots[Global.active_character]
	
	# Instantiate a SlotUI for each slot capacity
	for i in range(inv.capacity):
		var slot_node = slot_ui_scene.instantiate()
		grid_container.add_child(slot_node)

	render()

func render() -> void:
	var inv = Global.party_inventories.Slots[Global.active_character]
	var slot_nodes = grid_container.get_children()
	
	for i in range(inv.slots.size()):
		if i < slot_nodes.size():
			slot_nodes[i].update_slot(inv.slots[i])

func _on_inventory_updated(changed_index: int) -> void:
	if changed_index == character_index:
		render()
