extends Node
class_name HealthComponent

signal defeated

@export var start_health: int = 3
@export var max_health: int = 3

var current_health: int
var is_player_health_component: bool = false


func _ready() -> void:
	GameEvents.player_damaged.connect(on_player_damaged)
	current_health = max_health
	# Send out the player's health
	if owner.is_in_group("player"):
		current_health = start_health
		is_player_health_component = true
		GameEvents.emit_player_health_changed(current_health)
		if current_health == max_health:
			GameEvents.player_at_max_health = true


func check_health():
	prints(owner.name, "HealthComponent:", "check_health")
	if owner.is_in_group("player"):
		GameEvents.emit_player_health_changed(current_health)
		prints("\nplayer.health_component: current health = ", current_health, "max health = ", max_health)
		if current_health == max_health:
			GameEvents.player_at_max_health = true
		else:
			GameEvents.player_at_max_health = false
	
	if current_health <= 0:
		defeated.emit()


func take_damage(amount):
	damage(amount)
	if is_player_health_component:
		prints(owner.name, "HealthComponent:", "take_damage")
		#GameEvents.emit_player_damaged(amount)
	check_health()


func heal(amount):
	prints(owner.name, "HealthComponent:", "heal", amount)
	if current_health == max_health and is_player_health_component:
		current_health = max_health
		check_health()
	else:
		current_health += amount
		check_health()


func damage(amount):
	prints(owner.name, "HealthComponent:", "damage", amount)
	current_health -= amount

#
func on_player_damaged(amount):
	if is_player_health_component:
		prints(owner.name, "HealthComponent:", "on_player_damage", amount)
		damage(amount)
		check_health()
