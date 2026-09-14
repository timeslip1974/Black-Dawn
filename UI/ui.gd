extends Control

# Inside your parent UI manager or container script
@onready var party_container = $PartyContainer
var show_bar=false

func _ready() -> void:
	SignalManager.toggle_inventory.connect(inventory_toggle)
	# Loop through all character UI nodes in the grid
	for index in party_container.get_child_count():
		var slot = party_container.get_child(index)
		# Bind 'index' (or 'slot') to the custom signal handler
		slot.gui_input.connect(_on_character_clicked.bind(index, slot))
		slot.character_index=index

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



func _process(_delta: float) -> void:
	$FPS.text="FPS: %d" % Engine.get_frames_per_second()
	
func inventory_toggle():
	%MainBar/InventoryUI.setup_slots() # Update inv slots before displaying
	%MainBar.visible=!%MainBar.visible
