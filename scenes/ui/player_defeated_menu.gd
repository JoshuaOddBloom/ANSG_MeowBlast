extends CanvasLayer

#TODO STILL NEEDS TRANSITIONS FOR CONFIRMATIONS

@export var confirmation_timer_base_waittime: float

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var confirmation_timer: Timer = %ConfirmationTimer

@onready var choices: VBoxContainer = %Choices
@onready var restore_margin_container: MarginContainer = %RestoreMarginContainer
@onready var restore_button: Button = %RestoreButton
@onready var restart_button: Button = %RestartButton
@onready var leave_button: Button = %LeaveButton

@onready var confirm_progress_bar: ProgressBar = %ConfirmProgressBar
@onready var progress_notch_1: ColorRect = %ProgressNotch1
@onready var progress_notch_2: ColorRect = %ProgressNotch2
@onready var progress_notch_3: ColorRect = %ProgressNotch3

var option_chosen: String
var option_confirmed: bool = false
var almost_transparent: Color = Color(1.0, 1.0, 1.0, 0.25, )

func _ready() -> void:
	restore_margin_container.visible = GameEvents.player_can_restore
	
	## confirmation system
	confirmation_timer.timeout.connect(_on_confirmation_timer_timeout)
	#Button down
	restore_button.button_down.connect(_on_button_pressed.bind(restore_button))
	restart_button.button_down.connect(_on_button_pressed.bind(restart_button))
	leave_button.button_down.connect(_on_button_pressed.bind(leave_button))
	#button up
	restore_button.button_up.connect(stop_confirmation.bind(restore_button))
	restart_button.button_up.connect(stop_confirmation.bind(restart_button))
	leave_button.button_up.connect(stop_confirmation.bind(leave_button))
	# values
	confirmation_timer.wait_time = confirmation_timer_base_waittime
	confirm_progress_bar.max_value = confirmation_timer_base_waittime
	confirm_progress_bar.value = confirmation_timer_base_waittime


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		pass
	#NEEDS TO BE CHECKING THE BUTTON BEING PRESSED TO AVOID CONFLICT OF INPUT METHODS
	if ! confirmation_timer.is_stopped():
		confirm_progress_bar.value = confirmation_timer_base_waittime - confirmation_timer.time_left
	else:
		stop_confirmation(null)


func animation_player_play_restore():
	if GameEvents.player_can_restore:
		animation_player.play("restore")
	

func focus_first_available_choice():
	if GameEvents.player_can_restore:
		restore_button.grab_focus()
	else:
		restart_button.grab_focus()


func stop_confirmation(button: SoundButton):
	## called when the button is released too soon
	if ! option_confirmed:
		for i in get_tree().get_processed_tweens():
			i.kill()
		
		var stop_modulate_tween = get_tree().create_tween()
		stop_modulate_tween.tween_property(confirm_progress_bar, "modulate", Color.TRANSPARENT, 0.1)
		stop_modulate_tween.parallel().tween_property(progress_notch_1, "modulate", Color.TRANSPARENT, 0.1)
		stop_modulate_tween.parallel().tween_property(progress_notch_2, "modulate", Color.TRANSPARENT, 0.1)
		stop_modulate_tween.parallel().tween_property(progress_notch_3, "modulate", Color.TRANSPARENT, 0.1)
		stop_modulate_tween.parallel().tween_property(restore_button, "modulate", Color.WHITE, 0.15)
		stop_modulate_tween.parallel().tween_property(restart_button, "modulate", Color.WHITE, 0.15)
		stop_modulate_tween.parallel().tween_property(leave_button, "modulate", Color.WHITE, 0.15)
	
	else:
		confirm_progress_bar.value = confirmation_timer_base_waittime
		return
	
	if ! button == null:
		print("button released : ", button.name)
	
	if ! confirmation_timer.is_stopped():
		confirmation_timer.stop()
	option_chosen = ""


func _on_button_pressed(button: SoundButton):
	if option_confirmed:
		return
	
	Input.start_joy_vibration(0,.1, 0.1, 0.1) #First Vibration
	progress_notch_1.modulate = Color.WHITE
	
	for i in get_tree().get_processed_tweens():
			i.kill()
	
	confirm_progress_bar.modulate = Color.RED
	
	var pressed_modulate_tween = get_tree().create_tween()
	pressed_modulate_tween.tween_property(confirm_progress_bar, "modulate", Color.YELLOW, confirmation_timer_base_waittime/2)
	pressed_modulate_tween.parallel().tween_property(confirm_progress_bar, "modulate", Color.YELLOW, confirmation_timer_base_waittime/2)
	pressed_modulate_tween.chain().tween_callback(func(): Input.start_joy_vibration(0, .1, .1, .1);progress_notch_2.modulate = Color.WHITE)
	pressed_modulate_tween.chain().tween_property(confirm_progress_bar, "modulate", Color.GREEN, confirmation_timer_base_waittime/2)
	pressed_modulate_tween.chain().tween_callback(func(): progress_notch_3.modulate = Color.WHITE)
	#pressed_modulate_tween.chain().tween_property(confirm_progress_bar, "modulate", Color.GREEN, confirmation_timer_base_waittime)
	
	if button == null:
		return
	#Get the button's name
	option_chosen = button.name
	
	if confirmation_timer.is_stopped():
			confirmation_timer.start()
	
	print("button pressed : ", option_chosen)
	#if the button is released (button_up), stop_confirmation(button) will reset the confirmation


func _on_confirmation_timer_timeout():
	## If the timer concluded while button was held, Confirm the option that was held
	option_confirmed = true
	#Set unselected options to almost transparent
	
	match option_chosen:
				"":
					pass
				"RestoreButton":
					restart_button.modulate = almost_transparent
					leave_button.modulate = almost_transparent
				"RestartButton":
					restore_button.modulate = almost_transparent
					leave_button.modulate = almost_transparent
				"LeaveButton":
					restore_button.modulate = almost_transparent
					restart_button.modulate = almost_transparent
	
	restore_button.release_focus()
	restore_button.disabled = true
	restart_button.release_focus()
	restart_button.disabled = true
	leave_button.release_focus()
	leave_button.disabled = true
	
	Input.start_joy_vibration(0,.1, 0.1, 0.1)
	var confirmed_modulate_tween = create_tween()
	confirmed_modulate_tween.tween_property(confirm_progress_bar, "modulate", Color.WHITE, 0.2)
	confirmed_modulate_tween.chain().tween_property(confirm_progress_bar, "modulate", Color.TRANSPARENT, 1)
	## Choice Confirmed
	confirmed_modulate_tween.chain().tween_callback(func():
			match option_chosen:
				"":
					pass
				"RestoreButton":
					print("CONFIRMED : ", "RestoreButton")
					animation_player.play("out")
					await animation_player.animation_finished
					
					GameEvents.emit_player_restore()
					queue_free()
					
				"RestartButton":
					print("CONFIRMED : ", "RestartButton")
					animation_player.play("out")
					await animation_player.animation_finished
					
					ScreenTransition.transition()
					await ScreenTransition.transitioned_halfway
					get_tree().reload_current_scene()
					queue_free()
					
				"LeaveButton":
					print("CONFIRMED : ", "LeaveButton")
					animation_player.play("out")
					await animation_player.animation_finished
					
					ScreenTransition.transition_to_scene("res://scenes/ui/main_menu.tscn")
					#get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
					await ScreenTransition.transition_finished
					print("Defeat Menu Terminating")
					queue_free()
			
			)
