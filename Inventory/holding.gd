extends Control



func _ready() -> void:
	SignalManager.update_holding.connect(update_holding)
	visible = false
	# Ensure the sprite renders centered on the origin position
	$Holding.centered = true 
	# High z_index guarantees it draws above other 2D elements/nodes
	z_index = 100 
	z_as_relative = false

func _process(_delta: float) -> void:
	if visible:
		global_position = get_global_mouse_position()


func update_holding():
	await get_tree().process_frame
	visible=false

	if Global.holding.item!=null:
		print(Global.holding.item)
		visible=true
		$Holding.frame_coords=Global.holding.item.gfx_frame
