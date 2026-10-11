class_name  CameraComponent
extends Camera3D

@export var body:CharacterBody3D
var mouseSens = 0.002
var isGrim:bool = false
func _ready():
	# Hide and capture the mouse cursor
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if !isGrim:
		if event is InputEventMouseMotion:
			# Rotate body left/right (Y-axis)
			body.rotate_y(-event.relative.x * mouseSens)
			
			# Rotate camera up/down (X-axis) and clamp it
			rotate_x(-event.relative.y * mouseSens)
			rotation.x = clamp(rotation.x, deg_to_rad(-89), deg_to_rad(89))
