extends CharacterBody3D

var rDir: Vector3
var mDir: Vector3
var wait: bool
var is_attacking: bool = false
@onready var mesh: MeshInstance3D = $MeshInstance3D

@onready var wTimer: Timer = $wTimer
@onready var nav: NavigationAgent3D = $NavigationAgent3D
var player: CharacterBody3D
@onready var movementC: MovementComponent = $MovementComponent
@onready var healthC: HealthComponent = $HealthComponent

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	randomDir()
	wTimer.timeout.connect(randomDir)
	nav.set_navigation_map(get_world_3d().navigation_map)
	healthC.died.connect(death)
	healthC.start()
	
func _process(delta: float) -> void:
	if !is_inside_tree():
		return
	healthC.update()
	
func _physics_process(delta: float) -> void:
	if not player:
		return
		
	var dist_to_player = global_position.distance_to(player.global_position)
	
	if dist_to_player <= 2:
		if is_attacking:
			movementC.physics_update(delta, Vector3.ZERO, self)
			return
			
		is_attacking = true
		movementC.physics_update(delta, Vector3.ZERO, self)
		
		# Deal damage exactly once
		var health = player.get_node("HealthComponent")
		if is_instance_valid(health):
			health.take_damage(30)
		
		if is_inside_tree():	
			await get_tree().create_timer(1.0).timeout
		is_attacking = false
		
	elif dist_to_player <= 7:
		nav.target_position = player.global_position
		var next_path_pos = nav.get_next_path_position()
		look_at(next_path_pos, Vector3.UP)
		mDir = (next_path_pos - global_position).normalized()
		movementC.physics_update(delta, mDir, self)
		
	else:
		if wait:
			movementC.physics_update(delta, Vector3.ZERO, self)
			return
			
		if nav.is_navigation_finished():
			randomDir()
		

		var nextPathPosition: Vector3 = nav.get_next_path_position()
		look_at(nextPathPosition, Vector3.UP)
		mDir = (nextPathPosition - global_position).normalized()
		movementC.physics_update(delta, mDir, self)
	
	move_and_slide()
	# 1. Find the target position
	var next_path_pos = nav.get_next_path_position()

# 2. Create a look target at the exact same height (Y) as the character
	var look_target = Vector3(next_path_pos.x, global_position.y, next_path_pos.z)

# 3. Look at it (only if they aren't at the exact same spot)
	if global_position.distance_to(look_target) > 0.1:
		mesh.look_at(look_target, Vector3.UP)
func randomDir() -> void:
	wait = true
	await get_tree().create_timer(3.0).timeout
	wait = false
	
	rDir = Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
	nav.target_position = global_position + rDir
	wTimer.start()
	
func death():
	queue_free()
