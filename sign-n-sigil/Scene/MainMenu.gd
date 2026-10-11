extends Control


@onready var play: TextureButton = $Play

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play.button_down.connect(startGame)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func startGame():
	get_tree().change_scene_to_file("res://Scene/TestLevel.tscn")
