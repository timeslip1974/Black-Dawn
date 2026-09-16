class_name CharacterInventory
extends Resource

#Global.character_list.character[character number].inventory[inv s].item - accessed by

signal updated


@export var character_name: String = ""
@export var capacity: int = 21
@export var inventory: Array[InventorySlot] = []
@export var equipment:Array[InventorySlot]=[]
#head=0 chest=1 legs=2 feet=3 lh=4 rh=5




func _ready() -> void:
	# Ensures the slots array exactly matches capacity
	for c in range(equipment.size()):
		equipment[c]=InventorySlot.new()
	if inventory.size() != capacity:
		inventory.resize(capacity)
		for i in range(capacity):
			if inventory[i] == null:
				inventory[i] = InventorySlot.new()

func add_item(new_item: Item, amount: int = 1) -> bool:
	# 1. Try stacking into existing occupied slots
	for slot in inventory:
		if slot.item == new_item and slot.quantity < new_item.max_stack_size:
			var space = new_item.max_stack_size - slot.quantity
			var to_add = min(amount, space)
			slot.quantity += to_add
			amount -= to_add
			if amount <= 0:
				updated.emit()
				return true

	# 2. Try placing into the first empty slot within capacity limits
	for slot in inventory:
		if slot.item == null:
			slot.item = new_item
			slot.quantity = amount
			updated.emit()
			return true

	# Inventory is full (no slots remaining up to capacity)
	return false


	#remove 100 to slot_index to differ it from inv
func remove_item(slot_index):
	var temp=Global.holding
	
	if slot_index<99:
		Global.holding=inventory[slot_index]
		inventory[slot_index]=temp
		#if inventory[slot_index]==null:
		inventory[slot_index]=InventorySlot.new()
	else:
		Global.holding=equipment[slot_index-100]
		equipment[slot_index-100]=temp
		equipment[slot_index-100]=InventorySlot.new()
	
	SignalManager.update_holding.emit()
	SignalManager.update_inventory.emit()
	SignalManager.update_stats.emit()
	
func swap_item(slot_index):
	var temp=Global.holding
	if slot_index<99:
		Global.holding=inventory[slot_index]
		inventory[slot_index]=temp
	else:
		Global.holding=equipment[slot_index-100]
		equipment[slot_index-100]=temp
	
	SignalManager.update_holding.emit()
	SignalManager.update_inventory.emit()
	SignalManager.update_stats.emit()
	SignalManager.update_hands.emit()
	

	
