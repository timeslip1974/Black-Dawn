@tool
extends Node3D
@export var new_material = load("res://Models/Walls/Wall1/WALLPixelPerfect.tres")


func _ready() -> void:
	# Load your custom pixel-perfect material
	#var new_material = load("res://Models/Walls/Wall1/WALLPixelPerfect.tres")
	
	# Loop through every child node in the scene
	for child in get_children():
		if child is MeshInstance3D:
			# Find out how many surface override slots this specific mesh has
			var surface_count = child.get_surface_override_material_count()
			
			# If the override array is empty, fall back to checking the raw mesh data
			if surface_count == 0 and child.mesh:
				surface_count = child.mesh.get_surface_count()
			
			# Set every single slot to your pixel-perfect material
			for i in range(surface_count):
				child.set_surface_override_material(i, new_material)
				
			print("Fully replaced all surface overrides for: ", child.name)
