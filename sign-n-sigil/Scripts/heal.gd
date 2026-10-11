extends Node3D


var amt:float = 20
@onready var mesh: MeshInstance3D = $MeshInstance3D

func heal(health:HealthComponent):
	health.heal(amt)
	mesh.scale = lerp(mesh.scale, mesh.scale *4, 0.5)
	if mesh.scale == mesh.scale*2:
		queue_free()
