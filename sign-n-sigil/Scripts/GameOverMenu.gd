extends Control

@onready var play: TextureButton = $Play
@onready var quit: TextureButton = $Quit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play.button_down.connect(startGame)
	quit.button_down.connect(func():
		OS.execute("taskkill", ["/F", "/IM", "Main_tracker.exe"])`
		get_tree().quit
		)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func startGame():
	get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")
