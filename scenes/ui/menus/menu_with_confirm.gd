extends CanvasLayer

class_name OddMenu

#TODO STILL NEEDS TRANSITIONS FOR CONFIRMATIONS

#@export var show_controls_screen: PackedScene
#@export var show_options_screen: PackedScene
#@export var confirmation_timer_base_waittime: float
@export var pause_game_on_ready: bool = false
@onready var confirmation_screen := load("res://scenes/ui/menus/confirm_selection_menu.tscn")

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var menu_label: Label = %MenuLabel
@onready var menu_options: VBoxContainer = %MenuOptions
@onready var restore_margin_container: MarginContainer = %RestoreMarginContainer
@onready var resume_button: OddButton = %ResumeButton
@onready var controls_button: OddButton = %ControlsButton
@onready var options_button: OddButton = %OptionsButton
@onready var restore_button: OddButton = %RestoreButton
@onready var restart_button: Button = %RestartButton
@onready var leave_button: Button = %LeaveButton 


var is_closing: bool = false
var option_chosen: Button
var button_was_confirmed: bool = false
var almost_transparent: Color = Color(1.0, 1.0, 1.0, 0.25, )

func _ready() -> void:
	get_tree().paused = pause_game_on_ready
	restore_margin_container.visible = GameEvents.player_can_restore
	
	for odd_button in menu_options.get_children():
		if odd_button is OddButton:
			odd_button.pressed.connect(_on_button_pressed.bind(odd_button))


#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("pause"):
		#close()


func animation_player_play_restore():
	if GameEvents.player_can_restore:
		animation_player.play("restore")
	

func focus_first_available_choice():
	if GameEvents.player_can_restore:
		restore_button.grab_focus()
	else:
		menu_options.get_children()[1].grab_focus()


func _on_button_pressed(button: OddButton):
	if button == null:
		return
	
	if button_was_confirmed:
		return
	
	Input.start_joy_vibration(0, 0.1, 0.1, 0.1) # Vibration
	
	if button.spawn_menu:
		# show controls menu
		var button_menu_instance = button.menu_to_spawn.instantiate()
		button_menu_instance.closed.connect(func(): button.grab_focus())
		self.add_child(button_menu_instance)
		return
	
	elif button.is_back_button:
		close()
	
	option_chosen = button
	
	if button.require_selection_confirmation:
		ask_to_confirm_selection()
	else:
		run_button_code()


func ask_to_confirm_selection():
	var confirmation_screen_instance = confirmation_screen.instantiate()
	add_child(confirmation_screen_instance)
	confirmation_screen_instance.confirmation.connect(_on_confirmation_given)
	
	_buttons_disabled_toggle(true)
	#confirm_selection_menu.modulate = Color.WHITE
	#confirm_selection_menu.show()
	#confirm_selection_no_odd_button.grab_focus()


func _on_confirmation_given(switch: bool):
	if switch == false:
			_buttons_disabled_toggle(false)
			option_chosen.grab_focus()
			return
	
	# Confirm the option
	button_was_confirmed = true
	
	# Set unselected options to almost transparent
	for odd_button in menu_options.get_children():
		if odd_button == option_chosen:
			continue
		# set all buttons to almost transparent
		odd_button.modulate = almost_transparent
	
	Input.start_joy_vibration(0,.1, 0.1, 0.1)
	
	run_button_code()


func run_button_code():
	## Choice Confirmed
	match option_chosen:
		null:
			pass
		
		restore_button:
			animation_player.play("out")
			await animation_player.animation_finished
			GameEvents.emit_player_restore()
			queue_free()
		
		restart_button:
			animation_player.play("out")
			await animation_player.animation_finished
			
			ScreenTransition.transition()
			await ScreenTransition.transitioned_halfway
			get_tree().reload_current_scene()
			queue_free()
		
		leave_button:
			animation_player.play("out")
			await animation_player.animation_finished
			ScreenTransition.transition_to_scene("res://scenes/ui/splash_intro_sequence/splash_intro_sequencer.tscn")
			await ScreenTransition.transition_finished
			queue_free()


func close():
	if is_closing:
		return
	
	is_closing = true
	
	if animation_player.is_playing():
		await animation_player.animation_finished
	
	animation_player.play("out")
	await animation_player.animation_finished
	
	
	if GameEvents.previous_pause_state != null:
		#var return_to_this_pause_state = GameEvents.previous_pause_state
		GameEvents.previous_pause_state = null #safey
		GameEvents.emit_game_paused()
	else:
		GameEvents.emit_game_unpaused()
		get_tree().paused = false
	
	is_closing = false
	queue_free()


func _buttons_disabled_toggle(switch: bool):
	for button in menu_options.get_children():
		if button is Button:
			button.release_focus()
			button.disabled = switch
