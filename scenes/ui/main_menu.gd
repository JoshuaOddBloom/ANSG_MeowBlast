extends Control

@export var show_touch_screen_options: bool = false #BUG TODO NEED TO WORK ON ADDING THIS
@onready var controls_screen = preload("res://scenes/ui/show_controls_screen.tscn")
@onready var options_screen = preload("res://scenes/ui/show_options_screen.tscn")
@onready var bg: TextureRect = %BG
@onready var title: TextureRect = %Title
#@onready var start_button: TextureButton = %StartButton
@onready var marker_2d: Marker2D = $Branding/Marker2D
@onready var oddbloom_logo: Node2D = %OddbloomLogo
@onready var ansg_marker_2d: Marker2D = $Branding/ANSGMarker2D
@onready var ansg_sprite_2d: Sprite2D = $Branding/ANSGMarker2D/ANSGSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var start_button: OddButton = %StartButton
#@onready var touch_screen_start_button: TouchScreenButton = %TouchScreenStartButton
@onready var controls_button: OddButton = %ControlsButton
@onready var options_button: OddButton = %OptionsButton
#@onready var continue_sound_button: OddButton = %ContinueOddButton
# Input Method Selection
@onready var touch_screen_on_button: TouchScreenButton = %TouchScreenOnButton
@onready var touch_screen_off_button: Button = %TouchScreenOffButton
@onready var touch_screen_off_button_2: TouchScreenButton = %TouchScreenOffButton2
@onready var wait_to_start_timer: Timer = %WaitToStartTimer
@onready var menu_options: VBoxContainer = %MenuOptions


func _ready() -> void:
	wait_to_start_timer.timeout.connect(on_wait_to_start_timer_timeout)
	
	#for button in menu_options.get_children():
		#button.pressed.connect(on_start_button_pressed.bind(button))
	
	start_button.pressed.connect(on_start_button_pressed)
	#start_button.pressed.connect(on_start_button_pressed)
	controls_button.pressed.connect(on_controls_button_pressed)
	options_button.pressed.connect(on_options_button_pressed)
	#touch_screen_start_button.pressed.connect(on_start_button_pressed)
	#touch_screen_off_button_2.pressed.connect(on_touchscreen_button_pressed) # BUG MAY WANT TO FIX THIS TO WHERE IT USES A BOOLEAN TO SHOW TOUCH SCREEN OPTIONS
	#continue_sound_button.pressed.connect(on_continue_sound_button_pressed)
	
	if GameEvents.main_menu_shown_before or GameEvents.game_played:
		#disable_input_method_buttons()
		animation_player.play("auto_quick")
	else:
		wait_to_start_timer.start()
		#animation_player.play("ask_for_input_option") # Touch controls stuff
		
		#enable_input_method_buttons()
		#touch_screen_off_button.grab_focus()
	
	var new_pos = get_viewport_rect().size # THANK YOU STUDIOBOX GAMES (YT)
	marker_2d.position.x = new_pos.x / 2
	marker_2d.position.y = new_pos.y / 3
	
	ansg_marker_2d.position.x = new_pos.x / 2
	ansg_marker_2d.position.y = new_pos.y / 2


func on_wait_to_start_timer_timeout():
	#disable_input_method_buttons()
	animation_player.play("auto_quick")


func oddbloom_logo_queue_free():
	oddbloom_logo.queue_free()


func focus_start_button():
	start_button.disabled = false
	start_button.grab_focus()
	controls_button.disabled = false
	options_button.disabled = false





#func focus_continue_sound_button():
	#continue_sound_button.disabled = false
	#continue_sound_button.grab_focus()


func on_controls_button_pressed():
	controls_button.disabled = true

	var controls_screen_instance = controls_screen.instantiate()
	controls_screen_instance.closed.connect(on_controls_screen_closed)
	add_child(controls_screen_instance)
	controls_screen_instance.back_button.text = "BACK"


func on_options_button_pressed():
	options_button.disabled = true

	var options_screen_instance = options_screen.instantiate()
	options_screen_instance.closed.connect(on_options_screen_closed)
	add_child(options_screen_instance)
	#options_screen_instance.sound_button.text = "BACK"


func on_controls_screen_closed():
	controls_button.disabled = false
	controls_button.grab_focus()


func on_options_screen_closed():
	options_button.disabled = false
	options_button.grab_focus()


func on_start_button_pressed():
	start_button.disabled = true
	ScreenTransition.transition_to_scene("res://scenes/base_level/base_level.tscn")
	await ScreenTransition.transition_finished
	queue_free.call_deferred()

#
#func on_start_button_pressed():
	#start_button.disabled = true
	#touch_screen_start_button.disabled = true
	

#
#func _on_start_button_focus_entered() -> void:
	#start_button.modulate = Color(0.737, 0.765, 1.0, 1.0)

#
#func _on_start_button_focus_exited() -> void:
	#start_button.modulate = Color.WHITE

#
#func _on_touch_screen_button_pressed() -> void:
	##disable_input_method_buttons()
	#GameEvents.input_method = "touch"
	#load_main_menu()
#
#
#func _on_keyboard_and_mouse_button_pressed() -> void:
	##disable_input_method_buttons()
	#GameEvents.input_method = "keyboard"
	#load_main_menu()


func load_main_menu():
	animation_player.play_backwards("ask_for_input_option")
	await animation_player.animation_finished
	
	animation_player.play("auto_opening")
	GameEvents.main_menu_shown_before = true
	pass # Replace with function body.


#func disable_input_method_buttons():
	#touch_screen_off_button.disabled = true
	#touch_screen_on_button.process_mode = Node.PROCESS_MODE_DISABLED
#
#
#func enable_input_method_buttons():
	#touch_screen_off_button.disabled = false
	#touch_screen_on_button.process_mode = Node.PROCESS_MODE_INHERIT
