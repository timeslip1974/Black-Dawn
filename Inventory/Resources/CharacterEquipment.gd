class_name CharacterInventory
extends Resource

#Global.character_list.character[character number].inventory[inv s].item - accessed by


@export var character_name: String = ""
@export var capacity: int = 21
@export var inventory: Array[InventorySlot] = []
@export var head:InventorySlot
@export var chest:InventorySlot
@export var legs:InventorySlot
@export var feet:InventorySlot
@export var left_hand:InventorySlot
@export var right_hand:InventorySlot
