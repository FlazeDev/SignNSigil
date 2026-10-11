class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died

var max_health: int = 100

@export var current_health: int
@export var healthBar:ProgressBar

# Called when the node enters the scene tree for the first time.
func start() -> void:
	current_health = max_health
	if is_instance_valid(healthBar):
		healthBar.max_value = max_health
	health_changed.emit(current_health, max_health)

func update():
	if is_instance_valid(healthBar):
		healthBar.value = current_health

func take_damage(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return
	current_health -= amount
	if current_health <= 0:
		current_health = 0
		died.emit()
	print(get_parent(), "has taken damage of", amount)
	
func heal(amount: int) -> void:
	if amount <= 0:
		return
	current_health += amount
	if current_health >= 100:
		current_health = 100
	print(get_parent(), "has healed for", amount)
