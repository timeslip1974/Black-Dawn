extends PanelContainer
class_name SlotUI

@onready var gfx: Sprite2D = $graphics
@onready var quantity_label: Label = $Label

func update_slot(slot_data: InventorySlot) -> void:
	if slot_data and slot_data.item:
		$graphics.frame_coords = slot_data.item.gfx_frame
		if slot_data.quantity > 1:
			quantity_label.text = str(slot_data.quantity)
			quantity_label.show()
		else:
			quantity_label.hide()
	else:
		$graphics.hide()
		quantity_label.hide()
