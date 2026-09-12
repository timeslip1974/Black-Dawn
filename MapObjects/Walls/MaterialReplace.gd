@tool
extends Node

## Material assigned to Surface Material Override 0
@export var slot_0_material: Material:
	set(value):
		slot_0_material = value
		request_update()

## Material assigned to all other open slots (1, 2, 3, 4...)
@export var remaining_slots_material: Material:
	set(value):
		remaining_slots_material = value
		request_update()

var needs_update: bool = false

func request_update() -> void:
	needs_update = true

func _ready() -> void:
	if Engine.is_editor_hint():
		request_update()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() and needs_update:
		needs_update = false
		apply_materials(self)

func apply_materials(node: Node) -> void:
	if node is MeshInstance3D:
		# Ensure global override is clear so surface overrides take effect
		node.material_override = null
		
		# Get total surface overrides array size directly from node or mesh
		var count = node.get_surface_override_material_count()
		if count == 0 and node.mesh:
			count = node.mesh.get_surface_count()

		# Apply materials to each slot
		for i in range(count):
			if i == 0 and slot_0_material:
				node.set_surface_override_material(0, slot_0_material)
			elif i > 0 and remaining_slots_material:
				node.set_surface_override_material(i, remaining_slots_material)
				
		node.notify_property_list_changed()

	for child in node.get_children():
		apply_materials(child)
