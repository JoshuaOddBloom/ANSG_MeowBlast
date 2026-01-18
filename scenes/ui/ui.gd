extends CanvasLayer

signal init_finished

# UI
@onready var animation_player: AnimationPlayer = %AnimationPlayer
# Left Side UI
@onready var score_count_label: Label = %ScoreCountLabel
@onready var power_containers_h_box: HBoxContainer = %PowerContainersHBox
@onready var level_label: Label = %LevelLabel
@onready var projectile_count_label: Label = %ProjectileCountLabel
@onready var player_health_label: Label = %PlayerHealthLabel
@onready var ui_texture_rect_heart_container_icon = preload("res://scenes/ui/heart_container_icon.tscn")
@onready var heart_containers_hbox: GridContainer = %HeartContainersHBox
@onready var power_progress_bar: PanelContainer = %PowerProgressBar
@onready var power_button: Button = %PowerButton
@onready var power_touch_screen_button: TouchScreenButton = %PowerTouchScreenButton
# Center UI
@onready var enemy_health_bar: PanelContainer = %EnemyHealthBar
# Right Side UI
@onready var arena_time_ui: Control = %ArenaTimeUI
@onready var next_level_label: Label = %NextLevelLabel
@onready var increment_value_label: Label = $MarginContainer/HBoxContainer/PanelContainer2/RightUIVBox/VBoxContainer/VBoxContainer/IncrementValueLabel
@onready var next_level_progress_bar: ProgressBar = %NextLevelProgressBar
@onready var marker_top: TextureRect = %MarkerTop
@onready var marker_mid: TextureRect = %MarkerMid
@onready var marker_bottom: TextureRect = %MarkerBottom
@onready var fps_timer: Timer = %FPSTimer
@onready var fps_label: Label = %FPSLabel
@onready var shoot_speed_label: Label = %ShootSpeedLabel
@onready var move_speed_label: Label = %MoveSpeedLabel
@onready var projectile_size_label: Label = %ProjectileSizeLabel
@onready var pause_button: Button = %PauseButton
@onready var pause_touch_screen_button: TouchScreenButton = %PauseTouchScreenButton
# PLAYER DEFEATED MENU
@onready var menus_margin_container: MarginContainer = %MenusMarginContainer
@onready var game_over_triggered = false


var active_hearts = []
var current_hearts = 0
var heart_to_deplete = -1


func _ready() -> void:
	GameEvents.player_power_charged.connect(on_player_power_charged)
	GameEvents.player_power_used.connect(on_player_power_used)
	GameEvents.level_changed.connect(on_level_changed)
	GameEvents.level_incremement_changed.connect(on_level_incremement_changed)
	GameEvents.projectile_count_changed.connect(on_projectile_count_changed)
	GameEvents.score_count_changed.connect(on_score_count_changed)
	GameEvents.player_health_changed.connect(on_player_health_changed)
	GameEvents.player_damaged.connect(on_player_damaged)
	GameEvents.update_player_stats.connect(on_update_player_stats)
	GameEvents.game_paused.connect(_on_game_paused)
	GameEvents.game_ended.connect(on_game_over)
	
	power_button.pressed.connect(on_player_power_used)
	power_touch_screen_button.pressed.connect(on_player_power_used)
	
	score_count_label.text = "SCORE\n0"
	fps_timer.timeout.connect(on_fps_timer_timeout)
	#retry_button.pressed.connect(on_retry_button_pressed)
	enemy_health_bar.hide()
	level_increment_update()
	
	power_containers_h_box.hide()


func init():
	add_ui_heart_container_icon(6)
	await get_tree().create_timer(1.0).timeout
	for i in heart_containers_hbox.get_children():
		deplete_ui_heart_container_icon()
	
	await get_tree().create_timer(1.0).timeout
	
	var animation_list = animation_player.get_animation_list()
	for anim in animation_list:
		var original_loop_mode = animation_player.get_animation(anim).get_loop_mode()
		animation_player.get_animation(anim).set_loop_mode(Animation.LOOP_NONE)
		
		animation_player.play(anim)
		await animation_player.animation_finished
		animation_player.get_animation(anim).set_loop_mode(original_loop_mode)
	
	animation_player.play("RESET")
	
	init_finished.emit()
	hide()


# Heart Containers
func add_ui_heart_container_icon(hearts_to_add : int):
	for i in hearts_to_add:
		var new_heart = ui_texture_rect_heart_container_icon.instantiate()
		heart_containers_hbox.add_child(new_heart)


func update_current_hearts():
	var hearts = heart_containers_hbox.get_children()
	active_hearts = []
	for i in hearts:
		if i.active:
			active_hearts.append(i)
	
	current_hearts = len(active_hearts)


func deplete_ui_heart_container_icon():
	update_current_hearts() # get current active hearts
	if len(active_hearts) == 0:
		update_current_hearts()
		return
	active_hearts[len(active_hearts)-1].heart_depleated() # run heart_depleted() on the last heart in the group (switches hearts to inactive immediately)
	update_current_hearts() # update changes in active hearts for correctness
	#print("UI.deplete_ui_heart_container_icon.hearts : ", len(active_hearts))


func level_increment_update():
	next_level_progress_bar.value = GameEvents.current_level_incremement_value
	next_level_progress_bar.max_value = GameEvents.level_increment_target_value
	increment_value_label.text = str(GameEvents.current_level_incremement_value, " of ", GameEvents.level_increment_target_value)


func on_player_power_charged():
	animation_player.play("power_ready")


func on_player_power_used():
	animation_player.play("back_to_normal")


func on_projectile_count_changed(new_amount):
	projectile_count_label.text = str("Projectiles : ", new_amount)


func on_score_count_changed(new_amount):
	score_count_label.text = str("SCORE\n", new_amount)


func on_level_incremement_changed():
	level_increment_update()


func on_level_changed(new_level):
	if new_level >= GameEvents.max_level:
		next_level_label.text = str("")
		level_label.text = str("CRITICAL THREAT")
	else: 
		next_level_label.text = str("LEVEL -> ", new_level + 1)
		level_label.text = str("THREAT LEVEL ", GameEvents.current_level)
	
	match new_level:
		1:
			pass
		2:
			pass
		3:
			pass
		4:
			pass
		5:
			pass


func on_player_health_changed(new_amount):
	player_health_label.text = str("Health : ", new_amount)
	update_current_hearts()
	var hearts_diff = new_amount - current_hearts
	#print("UI.on_update_player_health : hearts_diff : ", hearts_diff)
	add_ui_heart_container_icon(hearts_diff)
	#print("active_hearts : ", active_hearts)


func on_player_damaged(damage_amount):
	animation_player.play("hit")
	for i in range(damage_amount):
		deplete_ui_heart_container_icon()


func _on_game_paused():
	menus_margin_container.add_child(GameEvents.pause_menu_scene.instantiate())


func on_game_over():
	if game_over_triggered == true:
		return
	else:
		game_over_triggered = true
		var player_defeated_menu_instance = GameEvents.player_defeated_menu.instantiate()
		menus_margin_container.add_child(player_defeated_menu_instance)


func on_start_button_pressed():
	animation_player.play("game_start")


func on_fps_timer_timeout():
	if ! fps_label.visible:
		fps_label.visible = true
	fps_label.text = str("FPS : ", Engine.get_frames_per_second())


func on_update_player_stats(stat: String, value: float):
	value = snappedf(value, 0.001)
	match stat:
		"shooting_speed":
			shoot_speed_label.text = str("AUTO-SHOOT SPEED :\n", value)
		"move_speed":
			move_speed_label.text = str("MOVE SPEED :\n", value)
		"projectile_size":
			projectile_size_label.text = str("PROJECTILE SIZE:\n", value)


func _on_pause_touch_screen_button_pressed() -> void:
	if GameEvents.can_pause:
		GameEvents.emit_game_paused() # Critical for pausing


func _on_pause_button_pressed() -> void:
	if GameEvents.can_pause:
		GameEvents.emit_game_paused()
