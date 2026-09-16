extends PanelContainer
class_name SlotUI

@onready var gfx: Sprite2D = $graphics
@onready var quantity_label: Label = $Label

signal slot_clicked # Signal to pass click back to invui scene

var current_slot_data: InventorySlot


func update_slot(slot_data: InventorySlot) -> void:
	# Store the direct reference (do NOT duplicate!)
	current_slot_data = slot_data
	
	# If ready, refresh immediately; otherwise _ready() will handle it on enter
	if is_node_ready():
		_refresh_display()


func _ready() -> void:
	# Guarantees visual update once the node enters the scene tree
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


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_clicked.emit()
