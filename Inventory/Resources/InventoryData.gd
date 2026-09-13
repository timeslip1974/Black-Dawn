class_name InventoryData
extends Resource

signal updated

@export var capacity: int = 21
@export var slots: Array[InventorySlot] = []

func initialize() -> void:
	# Ensures the slots array exactly matches capacity
	if slots.size() != capacity:
		slots.resize(capacity)
		for i in range(capacity):
			if slots[i] == null:
				slots[i] = InventorySlot.new()

func add_item(new_item: Item, amount: int = 1) -> bool:
	# 1. Try stacking into existing occupied slots
	for slot in slots:
		if slot.item == new_item and slot.quantity < new_item.max_stack_size:
			var space = new_item.max_stack_size - slot.quantity
			var to_add = min(amount, space)
			slot.quantity += to_add
			amount -= to_add
			if amount <= 0:
				updated.emit()
				return true

	# 2. Try placing into the first empty slot within capacity limits
	for slot in slots:
		if slot.item == null:
			slot.item = new_item
			slot.quantity = amount
			updated.emit()
			return true

	# Inventory is full (no slots remaining up to capacity)
	return false
