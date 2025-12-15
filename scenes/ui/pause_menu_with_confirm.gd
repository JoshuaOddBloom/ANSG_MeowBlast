extends CanvasLayer

#TODO STILL NEEDS TRANSITIONS FOR CONFIRMATIONS

@export var show_controls_screen: PackedScene
@export var show_options_screen: PackedScene
@export var confirmation_timer_base_waittime: float

@onready var animation_player: AnimationPlayer = %AnimationPlayer

@onready var choices: VBoxContainer = %Choices
@onready var restore_margin_container: MarginContainer = %RestoreMarginContainer
@onready var resume_button: SoundButton = %ResumeButton
@onready var controls_button: SoundButton = %ControlsButton
@onready var options_button: SoundButton = %OptionsButton
@onready var restore_button: Button = %RestoreButton
@onready var restart_button: Button = %RestartButton
@onready var leave_button: Button = %LeaveButton

@onready var confirm_selection_menu: MarginContainer = %ConfirmSelectionMenu
@onready var confirm_selection_no_sound_button: SoundButton = %ConfirmSelectionNoSoundButton
@onready var confirm_selection_yes_sound_button: SoundButton = %ConfirmSelectionYesSoundButton


var is_closing: bool = false
var option_chosen: Button
var button_was_confirmed: bool = false
var almost_transparent: Color = Color(1.0, 1.0, 1.0, 0.25, )

func _ready() -> void:
	get_tree().paused = true
	restore_margin_container.visible = GameEvents.player_can_restore
	
	#Button down
	resume_button.button_down.connect(_on_button_pressed.bind(resume_button))
	restore_button.button_down.connect(_on_button_pressed.bind(restore_button))
	controls_button.pressed.connect(_on_button_pressed.bind(controls_button))
	options_button.pressed.connect(_on_button_pressed.bind(options_button))
	restart_button.button_down.connect(_on_button_pressed.bind(restart_button))
	leave_button.button_down.connect(_on_button_pressed.bind(leave_button))
	confirm_selection_no_sound_button.pressed.connect(_on_confirmation.bind(confirm_selection_no_sound_button))
	confirm_selection_yes_sound_button.pressed.connect(_on_confirmation.bind(confirm_selection_yes_sound_button))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		pass
	#NEEDS TO BE CHECKING THE BUTTON BEING PRESSED TO AVOID CONFLICT OF INPUT METHODS


func is_fully_opened():
	pass


func animation_player_play_restore():
	if GameEvents.player_can_restore:
		animation_player.play("restore")
	

func focus_first_available_choice():
	if GameEvents.player_can_restore:
		restore_button.grab_focus()
	else:
		resume_button.grab_focus()


func _on_button_pressed(button: SoundButton):
	if button == null:
		return
	
	if button_was_confirmed:
		return
	
	Input.start_joy_vibration(0,.1, 0.1, 0.1) # Vibration
	
	# buttons that spawn menus
	if button == controls_button:
		#controls button pressed
		# show controls menu
		var controls_screen_instance = show_controls_screen.instantiate()
		controls_screen_instance.closed.connect(func(): controls_button.grab_focus())
		self.add_child(controls_screen_instance)
		return

	elif button == options_button:
		#controls button pressed
		# show options menu
		var options_screen_instance = show_options_screen.instantiate()
		options_screen_instance.closed.connect(func(): options_button.grab_focus())
		self.add_child(options_screen_instance)
		return
	
	elif button == resume_button:
		# skip confirmation
		#print("CONFIRMED : ", "ResumeButton")
		animation_player.play("out")
		await animation_player.animation_finished
			
		on_resume_pressed()
		pass
		
	
	#Get the button's name
	option_chosen = button
	
	ask_to_confirm_selection()
	#Resume does not need a confimation 
	#if confirmation_timer.is_stopped():
			#confirmation_timer.start()
	


func ask_to_confirm_selection():
	_buttons_disabled_toggle(true)
	confirm_selection_menu.modulate = Color.WHITE
	confirm_selection_menu.show()
	confirm_selection_no_sound_button.grab_focus()
	pass


func _on_confirmation(button: SoundButton):
	match button:
		confirm_selection_no_sound_button:
			var tween_confimation_screen = create_tween()
			tween_confimation_screen.tween_property(confirm_selection_menu, "modulate", Color.TRANSPARENT, 0.5)
			tween_confimation_screen.chain().tween_callback(confirm_selection_menu.hide)
			tween_confimation_screen.chain().tween_callback(_buttons_disabled_toggle.bind(false))
			tween_confimation_screen.chain().tween_callback(option_chosen.grab_focus)
			return
			
		confirm_selection_yes_sound_button:
			var tween_confimation_screen = create_tween()
			tween_confimation_screen.tween_property(confirm_selection_menu, "modulate", Color.TRANSPARENT, 0.5)
			pass
	
	## If the timer concluded while button was held, Confirm the option that was held
	button_was_confirmed = true
	
	#Set unselected options to almost transparent
	match option_chosen:
		#BUG I could literally do this more efficiently in a for loop and continuing if i = options_chosen... :)
		resume_button:
			restore_button.modulate = almost_transparent
			restart_button.modulate = almost_transparent
			leave_button.modulate = almost_transparent
		restore_button:
			resume_button.modulate = almost_transparent
			restart_button.modulate = almost_transparent
			leave_button.modulate = almost_transparent
		restart_button:
			restore_button.modulate = almost_transparent
			resume_button.modulate = almost_transparent
			leave_button.modulate = almost_transparent
		leave_button:
			restore_button.modulate = almost_transparent
			resume_button.modulate = almost_transparent
			restart_button.modulate = almost_transparent
	
	
	
	Input.start_joy_vibration(0,.1, 0.1, 0.1)
	
	#TODO may want to move this into it's own function?
	## Choice Confirmed
	match option_chosen:
		null:
			pass
		resume_button:
			#print("CONFIRMED : ", "ResumeButton")
			animation_player.play("out")
			await animation_player.animation_finished
			
			on_resume_pressed()
			
		restore_button:
			#print("CONFIRMED : ", "RestoreButton")
			animation_player.play("out")
			await animation_player.animation_finished
			
			GameEvents.emit_player_restore()
			queue_free()
			
		restart_button:
			#print("CONFIRMED : ", "RestartButton")
			animation_player.play("out")
			await animation_player.animation_finished
			
			ScreenTransition.transition()
			await ScreenTransition.transitioned_halfway
			get_tree().reload_current_scene()
			queue_free()
			
		leave_button:
			#print("CONFIRMED : ", "LeaveButton")
			animation_player.play("out")
			await animation_player.animation_finished
			
			ScreenTransition.transition_to_scene("res://scenes/ui/main_menu.tscn")
			#get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
			await ScreenTransition.transition_finished
			#print("Defeat Menu Terminating")
			queue_free()
	


func close():
	if is_closing:
		#print("Pause Menu: AlreadyClosing")
		return
	
	is_closing = true
	
	if animation_player.is_playing():
		await animation_player.animation_finished
	
	if GameEvents.previous_pause_state != null:
		var return_to_this_pause_state = GameEvents.previous_pause_state
		GameEvents.previous_pause_state = null #safey
		GameEvents.emit_game_paused(return_to_this_pause_state)
	else:
		GameEvents.emit_game_unpaused()
		get_tree().paused = false
	
	is_closing = false
	queue_free()


func on_resume_pressed():
	close()


func _buttons_disabled_toggle(switch: bool):
	resume_button.release_focus()
	resume_button.disabled = switch
	controls_button.release_focus()
	controls_button.disabled = switch
	options_button.release_focus()
	options_button.disabled = switch
	restore_button.release_focus()
	restore_button.disabled = switch
	restart_button.release_focus()
	restart_button.disabled = switch
	leave_button.release_focus()
	leave_button.disabled = switch
