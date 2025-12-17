extends Node2D

@export var enemy_scene: PackedScene
@export var enemy_spawn_timer_min_wait: float = 1.5
@export var enemy_spawn_timer_max_wait: float = 2.5

@onready var bgm_player: AudioStreamPlayer = %BGMPlayer

@onready var entities_layer: Node2D = %EntitiesLayer
@onready var player: Player = %Player
@onready var enemy_spawner_timer: Timer = $EnemySpawnerTimer
@onready var enemy_spawner_timer_2: Timer = %EnemySpawnerTimer2
@onready var enemy_spawner_timer_3: Timer = %EnemySpawnerTimer3
@onready var projectile_bounds: Area2D = %ProjectileBounds
@onready var hurt_box: Area2D = %HurtBox
# Levels
@onready var level_transition_player: AnimationPlayer = $BG/LevelTransitionPlayer
@onready var pattern_animation_player: AnimationPlayer = %PatternAnimationPlayer
@onready var game_over_rand_audio_component: RandomAudioStreamPlayer = %GameOverRandAudioComponent


var projectile_count : int = 0
var intensity_incremement_count: int = 0
var intensity_incremement_target: int = 25 # Counts to 10
var previous_score_adjustment: int = 0
var game_over: bool = false


func _ready() -> void:
	GameEvents.reset_values()
	GameEvents.score_count_changed.connect(on_score_count_changed)
	GameEvents.game_over.connect(on_game_over)
	enemy_spawner_timer.timeout.connect(on_enemy_spawner_timer_timeout)
	enemy_spawner_timer_2.timeout.connect(on_enemy_spawner_timer_2_timeout)
	enemy_spawner_timer_3.timeout.connect(on_enemy_spawner_timer_3_timeout)
	GameEvents.level_changed.connect(on_level_changed)
	# For UI initial status
	GameEvents.level_launch_signal_request()
	player.update_player_stats()
	projectile_bounds.area_entered.connect(on_projectile_bounds_entered)
	hurt_box.area_entered.connect(on_hurt_box_entered)
	GameEvents.game_played = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if game_over:
			return
		pause_game()
		get_tree().root.set_input_as_handled()
	
	if event.is_action_pressed("ui_text_backspace"):
		if player:
			player.take_damage(1)


func pause_game():
	if GameEvents.can_pause:
		GameEvents.emit_game_paused('paused') # Critical for pausing


func incremement_intensity():
	# if our score has gone up X points, increase the intensity by decreasing the enemy spawn timer's min and max wait times
	if intensity_incremement_count == intensity_incremement_target or intensity_incremement_count >= intensity_incremement_target:
		enemy_spawn_timer_min_wait *= 0.9
		enemy_spawn_timer_max_wait *= 0.95
		# Godot Timers bug out at .05, so we will never reach that value.
		if enemy_spawn_timer_min_wait < 0.5:
			enemy_spawn_timer_min_wait = 0.5
		if enemy_spawn_timer_max_wait < 0.75:
			enemy_spawn_timer_max_wait = 0.75
		
		
		previous_score_adjustment = GameEvents.score_count
		#prints("NEW SCORE REACHED", previous_score_adjustment)
		intensity_incremement_count = 0
		#prints("NEW WAIT TIME MIN AND MAX", enemy_spawn_timer_min_wait, enemy_spawn_timer_max_wait)


func create_enemy_instance(): 
	var _current_level = GameEvents.current_level
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.global_position = Vector2(randi_range(198, 442), -200)
	enemy_instance.fall_speed *= (0.4 * _current_level) + 1
	enemy_instance.scale = GameEvents.global_scale_target
	add_child(enemy_instance)


func on_enemy_spawner_timer_timeout():
	create_enemy_instance()
	enemy_spawner_timer.wait_time = randf_range(enemy_spawn_timer_min_wait, enemy_spawn_timer_max_wait)
	enemy_spawner_timer.start()


func on_enemy_spawner_timer_2_timeout():
	create_enemy_instance()
	enemy_spawner_timer_2.wait_time = randf_range(enemy_spawn_timer_min_wait, enemy_spawn_timer_max_wait) * 2
	enemy_spawner_timer_2.start()


func on_enemy_spawner_timer_3_timeout():
	create_enemy_instance()
	enemy_spawner_timer_3.wait_time = randf_range(enemy_spawn_timer_min_wait, enemy_spawn_timer_max_wait) * 3
	enemy_spawner_timer_3.start()


func on_score_count_changed(_new_amount):
	incremement_intensity()
	intensity_incremement_count += 1


func on_game_over():
	bgm_player.pitch_scale = 0.42
	bgm_player.pitch_scale_slide(0.42, .5)
	game_over_rand_audio_component.play_random()
	game_over = true


func on_projectile_bounds_entered(area: Area2D):
	if area.owner.is_in_group("projectile"):
		area.owner.defeated()


func on_hurt_box_entered(_area: Area2D):
	pass


func on_level_changed(new_level):
	match new_level:
		1:
			level_transition_player.play("level_1_start")
			GameEvents.level_increment_target_value = 10
		2:
			level_transition_player.play("level_1_to_level_2")
			GameEvents.level_increment_target_value = 20
		3:
			enemy_spawner_timer_2.start()
			level_transition_player.play("level_2_to_level_3")
			GameEvents.level_increment_target_value = 30
		4:
			level_transition_player.play("level_3_to_level_4")
			GameEvents.level_increment_target_value = 40
		5:
			level_transition_player.play("level_4_to_level_5")
			GameEvents.level_increment_target_value = 50
		6:
			enemy_spawner_timer_3.start()
	
