extends CanvasLayer

@onready var vignette = $Vignette
@onready var panel_container = %PanelContainer
@onready var resume_button: Button = %ResumeButton
@onready var options_button: Button = %OptionsButton
@onready var retry_button: Button = %RetryButton
@onready var quit_button: Button = %QuitButton

#var options_menu_scene = preload("res://scenes/ui/options_menu.tscn")
var options_menu_open: bool = false
var is_closing: bool = false

#TODO - PAUSE MENU
#TODO - PAUSE MENU - #BUG : When the pause menu is being closed, and the player tries to unpause, the game will freeze indefinitely in a paused state

func _ready():
	#GameEvents.emit_ui_right_side_ui_ability_icons_show_words("paused")
	get_tree().paused = true
	panel_container.pivot_offset = panel_container.size /2
	
	resume_button.pressed.connect(on_resume_pressed)
	options_button.pressed.connect(on_options_pressed)
	retry_button.pressed.connect(on_retry_pressed)
	quit_button.pressed.connect(on_quit_pressed)
	
	$AnimationPlayer.play("in")
	#play_vignette_animation("in") #being handled by the animation player via call method track
	
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel_container, "scale", Vector2.ONE, .4)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	$%ResumeButton.grab_focus()


func _unhandled_input(event):
	if event.is_action_pressed("pause") or Input.is_action_just_pressed("ui_cancel"):
		close()
	get_tree().root.set_input_as_handled()


func play_vignette_animation(anim:String):
	vignette.play_vignette_animation(anim)


func close():
	if is_closing:
		#print("Pause Menu: AlreadyClosing")
		return
	if options_menu_open:
		return
	is_closing = true
	
	$AnimationPlayer.play("out")
	#play_vignette_animation("out") #being handled by the animation player via call method track
	
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0)
	tween.tween_property(panel_container, "scale", Vector2.ZERO, .4)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	
	if GameEvents.previous_pause_state != null:
		var return_to_this_pause_state = GameEvents.previous_pause_state
		GameEvents.previous_pause_state = null #safey
		GameEvents.emit_game_paused(return_to_this_pause_state)
	else:
		GameEvents.emit_game_paused("done")
		get_tree().paused = false
	
	is_closing = false
	queue_free()


func on_resume_pressed():
	close()


func on_options_pressed():
	pass
	#options_menu_open = true
	#var options_menu_instance = options_menu_scene.instantiate()
	#panel_container.hide()
	#add_child(options_menu_instance)
	#options_menu_instance.back_pressed.connect(on_options_back_pressed.bind(options_menu_instance))
#
#
#func on_options_back_pressed(options_menu: Node):
	#panel_container.show()
	#options_menu_open = false
	#options_menu.queue_free()
	#options_button.grab_focus()


func on_quit_pressed():
	quit_button.disabled = true
	# Show Transition
	#ScreenTransition.transition()
	#await ScreenTransition.transitioned_halfway
	
	get_tree().paused = false
	get_tree().reload_current_scene()
	#get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	#ScreenTransition.skip_emit = true


func on_retry_pressed():
	quit_button.disabled = true
	# Show Transition
	#ScreenTransition.transition()
	#await ScreenTransition.transitioned_halfway
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/base_level/base_level.tscn")
	#ScreenTransition.skip_emit = true
