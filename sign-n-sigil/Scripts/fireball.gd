extends Area3D

@export var speed: float = 20.0
@export var damage: int = 100

var velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(5.0).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	global_position += velocity * delta

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"): 
		return
	if body.has_node("HealthComponent"):
		var health = body.get_node("HealthComponent")
		health.take_damage(damage)
