#@tool
extends Node

## Material assigned to Surface Material Override 0
@export var roof_material: Material:
	set(value):
		roof_material = value
		request_update()

## Material assigned to slots 1 through 4
@export var pillar_material: Material:
	set(value):
		pillar_material = value
		request_update()

## Material assigned to all remaining slots (5 and above)
@export var walls_material: Material:
	set(value):
		walls_material = value
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
		# Clear global override so individual surface overrides take effect
		node.material_override = null
		
		var count = node.get_surface_override_material_count()
		if count == 0 and node.mesh:
			count = node.mesh.get_surface_count()

		# Apply materials based on slot index
		for i in range(count):
			if i == 0 and roof_material:
				node.set_surface_override_material(0, roof_material)
			elif i in range(1, 5) and pillar_material:
				node.set_surface_override_material(i, pillar_material)
			elif i >= 5 and walls_material:
				node.set_surface_override_material(i, walls_material)
				
		node.notify_property_list_changed()

	for child in node.get_children():
		apply_materials(child)
