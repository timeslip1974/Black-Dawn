extends PanelContainer

	
func _ready() -> void:
	SignalManager.update_stats.connect(setup_slots)
	%head.slot_clicked.connect(_on_slot_clicked.bind(0))
	%chest.slot_clicked.connect(_on_slot_clicked.bind(1))
	%legs.slot_clicked.connect(_on_slot_clicked.bind(2))
	%feet.slot_clicked.connect(_on_slot_clicked.bind(3))
	%left_hand.slot_clicked.connect(_on_slot_clicked.bind(4))
	%right_hand.slot_clicked.connect(_on_slot_clicked.bind(5))

	
func setup_slots():
	var equipment=Global.character_list.character[Global.active_character].equipment
	print (equipment)
	%head.update_slot(equipment[0])
	%chest.update_slot(equipment[1])
	%legs.update_slot(equipment[2])
	%feet.update_slot(equipment[3])
	%left_hand.update_slot(equipment[4])
	%right_hand.update_slot(equipment[5])
	
func _on_slot_clicked(slot_index: int) -> void:
	#add 100 to slot_index to differ it from inv
	var equipment = Global.character_list.character[Global.active_character].equipment
	var slot_item = equipment[slot_index]

	if Global.holding == null and slot_item != null:
		Global.character_list.character[Global.active_character].remove_item(slot_index+100)
		
	elif Global.holding != null:
		# Place item into slot (or swap if slot already contains an item)
		Global.character_list.character[Global.active_character].swap_item(slot_index+100)
