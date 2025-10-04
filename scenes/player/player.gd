extends CharacterBody2D
class_name Player

@export var move_speed : float = 400.0
@export var max_move_speed: float = 550.0
@export var acceleration: int = 5
@export var power_charge_target: float = 50.0
# Systems
@onready var health_component: HealthComponent = $HealthComponent
@onready var semi_automatic_timer: Timer = $SemiAutomaticTimer
#@onready var boost_automatic_timer: Timer = $BoostAutomaticTimer
@onready var using_power_timer: Timer = $UsingPowerTimer
@onready var update_power_bar_value_timer: Timer = $UpdatePowerBarValueTimer
@onready var power_ready_gpu_particles_2d: GPUParticles2D = %PowerReadyGPUParticles2D
# Projectiles
@export var base_projectile = preload("res://scenes/projectile/base_projectile.tscn")
@export var projectile_base_x_10_scene = preload("res://scenes/projectile/projectile_base_x_10.tscn")
@onready var projectile_base_wait_time: float = 0.215
@export var projectile_minimum_wait_time: float = 0.125
@onready var projectile_spawn_marker_2d: Marker2D = %ProjectileSpawnMarker2D
# Audio
@onready var projectile_rand_audio_component: RandomAudioStreamPlayer = %ProjectileRandAudioComponent
@onready var damaged_random_audio_player_component: RandomAudioStreamPlayer = %DamagedRandomAudioPlayerComponent


#var current_projectile_selected
var is_init: bool = false
var can_shoot: bool = true
var power_charge_amount: float = 0.0
var power_previous_charge_amount: float = 0.0
var can_use_power: bool = false
var is_using_power: bool = false
var current_power: String = "base_x_10"
var lerp_scale_to_global_scale_target: bool = false


func _ready() -> void:
	GameEvents.use_power.connect(use_power)
	GameEvents.player_power_charged.connect(on_player_power_charged)
	GameEvents.get_player_health.connect(on_get_player_health)
	GameEvents.player_defeated.connect(on_player_defeated)
	GameEvents.player_damaged.connect(on_player_damaged)
	GameEvents.score_count_changed.connect(on_score_count_changed)
	GameEvents.item_drop_collected.connect(on_item_drop_collected)
	GameEvents.global_scale_target_changed.connect(on_global_scale_target_changed)
	#
	health_component.defeated.connect(on_player_defeated)
	semi_automatic_timer.timeout.connect(on_semi_automatic_timer_timeout)
	#boost_automatic_timer.timeout.connect(on_semi_automatic_timer_timeout)
	using_power_timer.timeout.connect(on_using_power_timer_timeout)
	
	GameEvents.emit_player_health_changed(health_component.current_health)
	power_ready_gpu_particles_2d.emitting = false
	semi_automatic_timer.wait_time = projectile_base_wait_time
	update_player_stats()


func _process(delta: float) -> void:
	if is_init:
		return
	## Input Monitoring
	
	if lerp_scale_to_global_scale_target:
		if scale != GameEvents.global_scale_target:
			scale = scale.lerp(GameEvents.global_scale_target, 1.0 - exp(-delta * GameEvents.global_scale_lerp_speed)) 
		elif scale == GameEvents.global_scale_target:
			lerp_scale_to_global_scale_target = false
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var global_mouse_position = get_global_mouse_position()
		if global_mouse_position.x <= 170 or global_mouse_position.x >= 470:
			return
		
		global_position.x = global_mouse_position.x
	
	# Move Left
	if Input.is_action_pressed("ui_left"):
		global_position.x -= move_speed * delta
	# Move Right
	elif Input.is_action_pressed("ui_right"):
		global_position.x += move_speed * delta
	
	# Fire Projectile
	if Input.is_action_just_pressed("shoot") or Input.is_action_just_pressed("mouse_button_left"):
		if ! can_shoot:
			# Cannot shoot, break out of loop
			return
		fire_projectile()
		
		semi_automatic_timer.start()
		
	elif Input.is_action_just_released("shoot") or Input.is_action_just_released("mouse_button_left"):
		semi_automatic_timer.stop()
	
	if Input.is_action_just_pressed("use_power") or Input.is_action_just_pressed("mouse_button_right"):
		use_power()
	
	move_and_slide()


func use_power():
	if can_use_power:
			projectile_base_wait_time = semi_automatic_timer.wait_time
			can_use_power = false
			is_using_power = true
			set_power_parameters()
			using_power_timer.start()
			update_power_bar_value_timer.start()


func update_player_stats():
	#print("UPDATE PLAYER STATS")
	GameEvents.emit_update_player_stats("move_speed", move_speed)
	GameEvents.emit_update_player_stats("shooting_speed", semi_automatic_timer.wait_time)
	GameEvents.player_update_power_value.emit(power_charge_amount, power_charge_target)



func set_power_parameters():
	match current_power:
		"base_x_10":
			using_power_timer.wait_time = 6.0
			semi_automatic_timer.wait_time *= 0.5
			power_charge_amount -= power_charge_target
	
	update_power_gauge(power_charge_amount, power_charge_target)


func fire_projectile():
	
	var projectile_instance
	
	if is_using_power:
		match current_power:
			"base_x_10":
				#print("BASEX10")
				projectile_instance = projectile_base_x_10_scene.instantiate()
		
	else:
		projectile_instance = base_projectile.instantiate()
	
	if projectile_instance == null:
		#print("projectile.gd.fire_projectile: projectile_scene not found")
		return
	
	projectile_instance.global_position = projectile_spawn_marker_2d.global_position
	projectile_rand_audio_component.play_random()
	get_parent().add_child(projectile_instance)


func reset_semi_automatic_timer_wait_time():
	semi_automatic_timer.wait_time = projectile_base_wait_time


func take_damage(amount):
	#BUG# ISN'T BEING CALLED
	#print("PlayerTakingDamage")
	damaged_random_audio_player_component.play_random()
	health_component.take_damage(amount)


func on_player_damaged(_amount):
	#print("PlayerTakingDamage")
	damaged_random_audio_player_component.play_random()


func update_power_gauge(current_power_charge_amount, current_power_target):
	GameEvents.emit_player_update_power_value(current_power_charge_amount, current_power_target)


func on_semi_automatic_timer_timeout():
	fire_projectile()


func on_player_power_charged():
	power_ready_gpu_particles_2d.emitting = true
	can_use_power = true


func on_using_power_timer_timeout():
	power_ready_gpu_particles_2d.emitting = false
	update_power_bar_value_timer.stop()
	reset_semi_automatic_timer_wait_time()
	is_using_power = false
	GameEvents.emit_player_power_used()
	
	if power_previous_charge_amount > 0.0:
		power_charge_amount = power_previous_charge_amount
		update_power_gauge(power_charge_amount, power_charge_target)
		GameEvents.emit_player_update_power_value(power_charge_amount, power_charge_target)
		power_previous_charge_amount = 0.0


func on_get_player_health():
	health_component.check_health()


func on_player_defeated():
	GameEvents.emit_game_over()
	queue_free()


func on_score_count_changed(_score):
	if is_using_power:
		return
	
	power_charge_amount += 5
	if power_charge_amount >= power_charge_target:
		GameEvents.emit_player_power_charged()
		power_charge_amount = power_charge_target
	
	update_power_gauge(power_charge_amount, power_charge_target)
	#prints("power charge amount :", power_charge_amount)


func on_global_scale_target_changed():
	if scale != GameEvents.global_scale_target:
		lerp_scale_to_global_scale_target = true



func on_item_drop_collected(item_resource_name):
	match item_resource_name:
		"power_up":
			power_previous_charge_amount = power_charge_amount
			update_power_gauge(power_charge_amount, power_charge_target)
			GameEvents.emit_player_update_power_value(power_charge_target, power_charge_target)
			can_use_power = true
			
		"max_hearts_up":
			if health_component.max_health >= 9:
				GameEvents.score_count += 500
			else:
				health_component.max_health += 1
				health_component.heal(1)
			
		"health_up":
			if health_component.current_health >= health_component.max_health:
				health_component.current_health = health_component.max_health
				GameEvents.emit_score_count_changed(500)
			else:
				health_component.heal(1)
			
		"move_speed_up":
			if move_speed >= max_move_speed:
				GameEvents.emit_score_count_changed(500)
				move_speed = max_move_speed
			else:
				move_speed *= 1.1
			GameEvents.emit_update_player_stats("move_speed", move_speed)
			
		"shooting_speed_up":
			
			if semi_automatic_timer.wait_time == projectile_minimum_wait_time or projectile_base_wait_time == projectile_minimum_wait_time:
				GameEvents.emit_score_count_changed(500)
				return
			
			if is_using_power and projectile_base_wait_time != projectile_minimum_wait_time:
				projectile_base_wait_time *= 0.95
				GameEvents.emit_update_player_stats("shooting_speed", projectile_base_wait_time)
				return
			
			var new_timer_value = semi_automatic_timer.wait_time * 0.95
			
			if new_timer_value < projectile_minimum_wait_time:
				GameEvents.emit_score_count_changed(500)
				semi_automatic_timer.wait_time = projectile_minimum_wait_time
			else:
				semi_automatic_timer.wait_time = new_timer_value
			
			GameEvents.emit_update_player_stats("shooting_speed", semi_automatic_timer.wait_time)
			
