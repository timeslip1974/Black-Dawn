@tool
extends Node3D

@export var new_material = load("res://MapObjects/Walls/Set1/WallTexture1.png")
@export var new_material2 = load("res://MapObjects/Walls/Set1/WallTexture2.png")
@export var new_material3 = load("res://MapObjects/Walls/Set1/WallTexture3.png")

# BYPASS FIX: An export checkbox that triggers a function, acting exactly like a button
@export var Click_To_Swap_Materials: bool = false:
	set(value):
		if value == true:
			apply_materials()

func _ready() -> void:
	pass

func apply_materials() -> void:
	var count = 0
	print("--- Starting Material Override Swap ---")
	
	for child in get_children():
		if child is MeshInstance3D:
			# Get the actual number of active slots
			var surface_count = child.get_surface_override_material_count()
			if surface_count == 0 and child.mesh:
				surface_count = child.mesh.get_surface_count()
			
			# Apply materials based on structural count blocks
			for i in range(surface_count):
				if count >= 0 and count < 15:
					child.set_surface_override_material(i, new_material)
				elif count >= 15 and count < 31:
					child.set_surface_override_material(i, new_material2)
				else:
					child.set_surface_override_material(i, new_material3)
					
			var active_mat = child.get_surface_override_material(0)
			if active_mat:
				print("Swapped: ", child.name, " | Index: ", count, " | Material: ", active_mat.resource_path.get_file())
			else:
				print("Swapped: ", child.name, " | Index: ", count, " | Material: None")
			
			# Increment ONLY for actual mesh nodes
			count += 1
			
	# Automatically reset the checkbox back to false in the inspector
	Click_To_Swap_Materials = false
	notify_property_list_changed()
