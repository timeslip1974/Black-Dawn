extends Control

# Inside your parent UI manager or container script
@onready var party_container = $PartyContainer

var show_bar=false

func _ready() -> void:
	SignalManager.toggle_inventory.connect(inventory_toggle)
	SignalManager.update_stats.connect(update_hands)
	# Loop through all character UI nodes in the grid
func init():
	for index in party_container.get_child_count():
		var slot = party_container.get_child(index)
		# Bind 'index' (or 'slot') to the custom signal handler
		slot.gui_input.connect(_on_character_clicked.bind(index, slot))
		slot.character_index=index
	update_hands()

func _on_character_clicked(event: InputEvent, character_index: int, slot_node: Control) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Global.active_character=character_index
		print("Active Player: ", character_index)
		print("Node name: ", slot_node.name)
		for slot in party_container.get_children():
			if slot.get_index()==Global.active_character:
				slot.set_active(true)
			else:slot.set_active(false)
		%InventoryUI.update_inventory()

func update_hands() -> void:
	var char_array = Global.character_list.character
	
	for i in range(party_container.get_child_count()):
		if i >= char_array.size():
			break
			
		var slot_node = party_container.get_child(i)
		
		# Find hand slots dynamically regardless of container nesting depth
		var left_ui = slot_node.find_child("lefthand", true, false)
		var right_ui = slot_node.find_child("righthand", true, false)
		
		if left_ui and right_ui:
			left_ui.update_slot(char_array[i].equipment[4])
			right_ui.update_slot(char_array[i].equipment[5])

func _process(_delta: float) -> void:
	$FPS.text="FPS: %d" % Engine.get_frames_per_second()
	
func inventory_toggle():
	%InventoryUI.setup_slots() # Update inv slots before displaying
	$MainBar/StatsUI.setup_slots()
	%MainBar.visible=!%MainBar.visible
