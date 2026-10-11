class_name GrimoireComponent
extends Node3D

@export var slot_1: TextureRect
@export var slot_2: TextureRect
@export var slot_3: TextureRect
@export var slot_4: TextureRect
@export var camera_display: TextureRect 

const G_FIST = preload("res://Assets/GreenClosedFist.png")
const G_POINT = preload("res://Assets/GreenPointUp.png")
const G_THUMBS = preload("res://Assets/GreenThumbsUp.png")
const G_VICTORY = preload("res://Assets/GreenVictory.png")

var fireballScene = preload("res://Scene/Fireball.tscn")
var healScene = preload("res://Scene/Heal.tscn")

var cSpell: Array[String] = []
var fireBall: Array[String] = ["Victory", "ThumbsUp", "PointUp", "ClosedFist"]
var heal: Array[String] = ["ThumbsUp", "ClosedFist", "PointUp", "Victory"]
var wall: Array[String] = ["ClosedFist", "PointUp", "ThumbsUp", "Victory"]

var sTimer: Timer
var udp_peer := PacketPeerUDP.new()
const PORT_VIDEO = 4244

@export var combo_timeout: float = 3.0
@onready var grimoireL: CanvasLayer = $"../GrimoireLayer"
@export var spawnPoint: Node3D

var is_spell_frozen: bool = false 

func start() -> void:
	cSpell =[]
	is_spell_frozen = false
	
	if udp_peer.bind(PORT_VIDEO) == OK:
		print("Godot high-speed video listener active on port ", PORT_VIDEO)
	
	sTimer = Timer.new()
	add_child(sTimer)
	sTimer.one_shot = true
	sTimer.wait_time = combo_timeout
	sTimer.process_mode = Node.PROCESS_MODE_ALWAYS 
	sTimer.timeout.connect(_on_spell_timeout)
	
	_clear_ui_textures()

func update(_delta: float) -> void:
	if not is_inside_tree() or not is_instance_valid(spawnPoint) or not spawnPoint.is_inside_tree():
		return

	grimoireL.visible = true
	Engine.time_scale = 0.1 
	spellCheck()
	
	_receive_network_video()
	
	if is_spell_frozen:
		return
		
	if cSpell == fireBall:
		shoot_fireball()
		print("Cast: FireBall")
		finish_spell_cast("Fireball cast successfully!")
	elif cSpell == heal:
		Heal()
		print("Cast: Heal")
		finish_spell_cast("Heal cast successfully!")
	elif cSpell == wall:
		print("Cast: Wall")
		finish_spell_cast("Wall cast successfully!")
		
	if len(cSpell) >= 4 and not is_spell_frozen:
		clear_combo("Sequence full without match. Clearing.")

func _receive_network_video() -> void:
	if camera_display and udp_peer.get_available_packet_count() > 0:
		var packet = udp_peer.get_packet()
		var image = Image.new()
		var error = image.load_jpg_from_buffer(packet)
		if error == OK:
			camera_display.texture = ImageTexture.create_from_image(image)

func spellCheck() -> void:
	var gesture_inputs = ["ThumbsUp", "ClosedFist", "PointUp", "Victory"]
	
	for gesture in gesture_inputs:
		if Input.is_action_just_pressed(gesture):
			if cSpell != [] and cSpell[-1] == gesture and not is_spell_frozen:
				return
			
			if is_spell_frozen:
				_clear_ui_textures()
				cSpell.clear()
				is_spell_frozen = false
				print("--- Starting New Spell Casting Sequence ---")
				
			cSpell.append(gesture)
			print("Added symbol: ", gesture, " | Current Chain: ", cSpell)
			
			_update_slot_ui(cSpell.size(), gesture)
			sTimer.start(combo_timeout) 

func _update_slot_ui(slot_index: int, gesture_name: String) -> void:
	var target_texture: Texture2D = null
	match gesture_name:
		"ClosedFist": target_texture = G_FIST
		"PointUp": target_texture = G_POINT
		"ThumbsUp": target_texture = G_THUMBS
		"Victory": target_texture = G_VICTORY
	
	match slot_index:
		1: if slot_1: slot_1.texture = target_texture
		2: if slot_2: slot_2.texture = target_texture
		3: if slot_3: slot_3.texture = target_texture
		4: if slot_4: slot_4.texture = target_texture

func _clear_ui_textures() -> void:
	if slot_1: slot_1.texture = null
	if slot_2: slot_2.texture = null
	if slot_3: slot_3.texture = null
	if slot_4: slot_4.texture = null

func _on_spell_timeout() -> void:
	clear_combo("Time expired! Combo dropped.")

func finish_spell_cast(reason: String) -> void:
	sTimer.stop()
	Engine.time_scale = 1.0 
	is_spell_frozen = true   
	print(reason)

func clear_combo(reason: String) -> void:
	cSpell.clear()
	sTimer.stop()
	Engine.time_scale = 1.0
	is_spell_frozen = false
	print(reason)
	_clear_ui_textures()
	
func shoot_fireball() -> void:
	if not fireballScene:
		return
	if not is_instance_valid(spawnPoint) or not spawnPoint.is_inside_tree():
		return
		
	var fireball = fireballScene.instantiate()
	get_tree().root.add_child(fireball)
	fireball.global_position = spawnPoint.global_position
	var forward_direction = -spawnPoint.global_transform.basis.z.normalized()
	fireball.velocity = forward_direction * fireball.speed
	
	
func Heal() -> void:
	var healInst = healScene.instantiate()
	get_tree().root.add_child(healInst)
	healInst.global_position = $"../Camera3D".global_position
	healInst.heal($"../HealthComponent")
