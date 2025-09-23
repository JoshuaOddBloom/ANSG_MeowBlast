extends Node2D

# UI and Level signals
signal score_count_changed(new_score)
signal level_changed(new_level)
signal level_incremement_changed
signal projectile_count_changed(new_projectile_count)
# Game-flow elements
signal global_scale_target_changed
signal update_player_stats(stat: String, value: float)
signal player_power_charged
signal player_power_used
signal player_power_being_used
signal player_update_power_value(current_power, power_target)
signal get_player_health
signal player_health_changed(new_player_health_amount)
signal player_damaged(amount)
signal player_defeated
signal player_restored
signal game_over
# Pausing
signal game_paused(occassion)
# Item Drops
signal item_drop_collected(item_resource_name: String)
signal item_drop_requested(location)
signal item_drop_send(item_drop_type : String, item_drop_data : Resource)


@onready var enemy_sprite_attack1: Texture = preload("res://scenes/enemy/CateroidChaosEnemies_attack1.png")
@onready var enemy_sprite_defeated1 = preload("res://scenes/enemy/CateroidChaosEnemies_defeated1.png")
@onready var enemy_sprite_hurt1: Texture = preload("res://scenes/enemy/CateroidChaosEnemies_hurt1.png")
@onready var enemy_sprite_hurt2 = preload("res://scenes/enemy/CateroidChaosEnemies_hurt2.png")
@onready var enemy_sprite_idle1 = preload("res://scenes/enemy/CateroidChaosEnemies_idle1.png")

var player_can_restore: bool = false
var player_at_max_health: bool = false
var max_level: int = 99
var current_level: int = 1
var current_level_incremement_value: int = 0
var level_increment_target_value: int = 10

var score_count: int = 0
var projectile_count: int = 0
# pausing
var can_pause: bool = true
var pause_menu_scene = preload("res://scenes/ui/pause_menu_press_and_hold.tscn")
var previous_pause_state
var main_menu_shown_before: bool = false
var game_played: bool = false

var global_scale_lerp_speed: float = .1
var global_scale_target: Vector2 = Vector2(1.0, 1.0)


func reset_values():
	score_count = 0
	projectile_count = 0
	current_level = 1
	current_level_incremement_value = 0


func level_launch_signal_request():
	reset_values()
	emit_projectile_count_changed(projectile_count)
	emit_level_incremement_changed()
	
	get_player_health.emit()
	emit_level_changed(current_level)


func get_player_position():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	else:
		return player.global_position


func check_level_incremement():
	if current_level_incremement_value >= level_increment_target_value:
		if current_level == max_level:
			# do something with power-ups
			current_level_incremement_value = 0
			
		else:
			current_level += 1
			emit_level_changed(current_level)
			current_level_incremement_value = 0
		level_incremement_changed.emit()


func increment_level(amount):
	current_level_incremement_value += amount
	level_incremement_changed.emit()
	check_level_incremement()


func change_global_scale_target(new_target_float: float):
	global_scale_target = Vector2(new_target_float, new_target_float)
	emit_global_scale_target_changed()


func emit_global_scale_target_changed():
	global_scale_target_changed.emit()


func emit_score_count_changed(amount_changed):
	score_count += amount_changed
	score_count_changed.emit(score_count*5)


func emit_level_incremement_changed():
	level_incremement_changed.emit()


func emit_level_changed(new_level):
	level_changed.emit(new_level)


func emit_projectile_count_changed(amount_changed):
	projectile_count += amount_changed
	if projectile_count < 0:
		projectile_count = 0
	projectile_count_changed.emit(projectile_count)


func emit_player_power_charged():
	player_power_charged.emit()


func emit_player_power_used():
	player_power_used.emit()


func emit_update_player_stats(stat: String, value: float):
	update_player_stats.emit(stat, value)


func emit_player_power_being_used():
	player_power_being_used.emit()


func emit_player_update_power_value(current_power, power_target):
	player_update_power_value.emit(current_power, power_target)


func emit_player_health_changed(new_amount):
	player_health_changed.emit(new_amount)


func emit_player_damaged(amount):
	player_damaged.emit(amount)


func emit_player_defeated():
	player_defeated.emit()


func emit_player_restored():
	player_restored.emit()


func emit_game_over():
	game_over.emit()


func emit_game_paused(occassion): #good for adding animations to static elements while the game is paused
	## NOTE: EVERY EMIT SHOULD HAVE AN OCCASSION : "done" for when the game is resuming
	game_paused.emit(occassion)


# ITEM DROPS
func emit_item_drop_collected(item_resource_name: String):
	item_drop_collected.emit(item_resource_name)


func emit_item_drop_requested(location):
	item_drop_requested.emit(location)


func emit_item_drop_send(item_drop_type : String, item_drop_data : Resource):
	item_drop_send.emit(item_drop_type, item_drop_data)
