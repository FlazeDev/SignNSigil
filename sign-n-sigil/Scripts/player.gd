extends CharacterBody3D

@onready var inputC: InputComponent = $InputComponent
@onready var movementC: MovementComponent = $MovementComponent
@onready var grimoireC: GrimoireComponent = $GrimoireComponent
@onready var healthC: HealthComponent = $HealthComponent
@onready var grimoireL: CanvasLayer = $GrimoireLayer
@onready var loadingScreen: TextureRect = $LoadingScreen/TextureRect

func _ready() -> void:
	grimoireC.start()
	healthC.start()
	healthC.died.connect(death)
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Exit"):
		OS.execute("taskkill", ["/F", "/IM", "Main_tracker.exe"])
		get_tree().quit()
	loadingScreen.modulate.a -= 0.05
	movementC.jump = inputC.jump
	if inputC.startGrim:
		grimoireC.clear_combo("Starting")
	if inputC.grimoire:
		grimoireC.update(delta)
	else:
		Engine.time_scale = 1.0
		grimoireL.visible = false
	healthC.update()
	inputC.update(delta)

func _physics_process(delta: float) -> void:
	movementC.physics_update(delta, (global_transform.basis * Vector3(inputC.dir.x, 0, inputC.dir.y)).normalized(), self)
	self.move_and_slide()
	
func death():
	queue_free()
	get_tree().change_scene_to_file("res://Scene/GameOverMenu.tscn")
	print("so bad you are ma")
