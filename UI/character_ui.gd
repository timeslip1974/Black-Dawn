extends PanelContainer

const SELECTED:StyleBox=preload("res://Styles/WindowOutlineHighlighted.tres")
const UNSELECTED:StyleBox=preload("res://Styles/WindowOutline.tres")
var character_index


	
func set_active(is_selected):
	if is_selected:
		self.add_theme_stylebox_override("panel",SELECTED)
	else:
		self.add_theme_stylebox_override("panel",UNSELECTED)


func _on_portait_box_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Global.active_character=character_index
		SignalManager.toggle_inventory.emit()
		
