class_name MovementComponent
extends Node


@onready var body: CharacterBody3D = $".."
@export var speed:float = 5.0
var jump:bool = false
@export var jumpVel:float = 6

var grounded:bool

func physics_update(delta: float, movedir:Vector3, body:CharacterBody3D) -> void:
	grounded = body.is_on_floor()
	if grounded:
		body.velocity.x = speed * movedir.x
		body.velocity.z = speed * movedir.z
		body.velocity.y = -0.1
		if jump:
			body.velocity.y = jumpVel
	else:
		if body.velocity.y < 0:
			body.velocity.y += body.get_gravity().y * delta * 2
		else:
			body.velocity.y += body.get_gravity().y * delta
