extends Node3D

@export var light_col=Color(1, 1, 1, 1)
var mesh: MeshInstance3D 

func _ready() -> void:
	mesh=$Light
	change_light_color()
		
func change_light_color() -> void:
	var material = mesh.get_active_material(0) as StandardMaterial3D
	if material:
		material = material.duplicate()
		mesh.set_surface_override_material(0, material) # Clean and efficient!
		
		material.emission_enabled = true
		material.emission = light_col
		
	$AreaLight3D.light_color=light_col
