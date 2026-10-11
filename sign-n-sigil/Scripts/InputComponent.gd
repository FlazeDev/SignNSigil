class_name InputComponent
extends Node

var dir:Vector2
var grimoire:bool
var jump:bool
var startGrim:bool
func update(delta:float):
	dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	grimoire = Input.is_action_pressed("Grimoire")
	startGrim = Input.is_action_just_pressed("Grimoire")
	jump = Input.is_action_just_pressed('Jump')
	
