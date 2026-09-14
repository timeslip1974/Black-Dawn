extends PanelContainer
class_name SlotUI

@onready var gfx: Sprite2D = $graphics
@onready var quantity_label: Label = $Label

var current_slot_data: InventorySlot

func _ready() -> void:
	pass
	# Draw immediately once the node enters the scene tree
#	_refresh_display()

func update_slot(slot_data: InventorySlot) -> void:
	current_slot_data = slot_data.duplicate()
	if is_node_ready():
		_refresh_display()

func _refresh_display() -> void:
	if current_slot_data and current_slot_data.item:
		gfx.frame_coords = current_slot_data.item.gfx_frame
		gfx.show()
		
		if current_slot_data.quantity > 1:
			quantity_label.text = str(current_slot_data.quantity)
			quantity_label.show()
		else:
			quantity_label.hide()
	else:
		gfx.hide()
		quantity_label.hide()
