extends Control

@onready var main_menu = preload("res://scenes/ui/main_menu.tscn")
@onready var show_controls_screen = preload("res://scenes/ui/show_controls_screen.tscn")
@onready var timer: Timer = $Timer
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var label: Label = %Label
@onready var color_rect: ColorRect = %ColorRect
@onready var loading_layer: CanvasLayer = %LoadingLayer
@onready var ui: CanvasLayer = %UI
@onready var enemy: Node2D = $Node2D/Enemy
@onready var player: Player = $Node2D/Player
@onready var item_drop_manager: Node = %ItemDropManager

var init_ui_finished: bool = false
var can_proceed: bool = false

func _ready() -> void:
	progress_bar.hide()
	get_window().grab_focus()
	timer.timeout.connect(on_timer_timeout)
	progress_bar.max_value = timer.wait_time
	ui.init_finished.connect(func(): 
		init_ui_finished = true; 
		#loading_layer.layer = -1; 
		enemy.init(); 
		player.hide()
		)
	enemy.init_finished.connect(func(): enemy.hide(); loading_layer.layer = 50)
	ui.init()
	player.is_init = true
	item_drop_manager.init()
	
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)


func _process(_delta: float) -> void:
	if progress_bar.value < progress_bar.max_value * 0.25:
		label.text = "LOADING"
	if progress_bar.value > progress_bar.max_value * 0.25:
		label.text = "LOADING."
	if progress_bar.value > progress_bar.max_value * 0.50:
		label.text = "LOADING.."
	if progress_bar.value > progress_bar.max_value * 0.75:
		label.text = "LOADING..."
	progress_bar.value = timer.wait_time - timer.time_left
	
	if init_ui_finished:
		can_proceed = true


func on_timer_timeout():
	if ! can_proceed:
		timer.start()
		return
	
	label.hide()
	loading_layer.layer = -1
	# Unmute the Master audio bus
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	# Create the controls screen
	var show_controls_screen_instance = show_controls_screen.instantiate()
	show_controls_screen_instance.closed.connect(on_sound_button_pressed)
	add_child(show_controls_screen_instance)
	show_controls_screen_instance.sound_button.text = "CONTINUE"


func on_sound_button_pressed():
	get_tree().change_scene_to_packed(main_menu)
