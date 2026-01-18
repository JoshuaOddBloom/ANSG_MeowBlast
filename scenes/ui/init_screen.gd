extends Control

#@export var intro_sequencer: PackedScene # = preload("res://scenes/ui/main_menu.tscn")
@export var loading_text: String
@export var show_loading_label: bool = true
@export var add_dots_to_label: bool = true
@export var show_loading_progress_bar: bool = true
@onready var show_controls_screen = preload("res://scenes/ui/menus/show_controls_screen.tscn")
@onready var timer: Timer = $Timer
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var loading_label: Label = %Label
@onready var color_rect: ColorRect = %ColorRect
@onready var loading_layer: CanvasLayer = %LoadingLayer
@onready var ui: CanvasLayer = %UI
@onready var enemy: Node2D = $Node2D/Enemy
@onready var player: Player = $Node2D/Player
@onready var item_drop_manager: Node = %ItemDropManager
@onready var base_level: Node2D = $Node2D/BaseLevel

var init_ui_finished: bool = false
var can_proceed: bool = false


func _ready() -> void:
	AudioServer.set_bus_mute(0, true)
	player.is_init = true
	GameEvents.can_pause = false
	loading_label.text = loading_text
	loading_label.visible = show_loading_label
	progress_bar.visible = show_loading_progress_bar
	get_window().grab_focus()
	timer.timeout.connect(on_timer_timeout)
	ui.init_finished.connect(func(): 
		init_ui_finished = true;
		ParticlesInit.init();
		if enemy:
			enemy.init(); 
		if player:
			player.hide();
		if ui:
			ui.queue_free() # This will free the pause menu
		)
	enemy.init_finished.connect(func(): enemy.hide(); loading_layer.layer = 50)
	progress_bar.max_value = timer.wait_time
	ui.init()
	base_level.init()
	item_drop_manager.init()


func _process(_delta: float) -> void:
	if GameEvents.can_pause:
		GameEvents.can_pause = false
	if add_dots_to_label:
		if progress_bar.value < progress_bar.max_value * 0.25:
			loading_label.text = str(loading_text,"")
		if progress_bar.value > progress_bar.max_value * 0.25:
			loading_label.text = str(loading_text,".")
		if progress_bar.value > progress_bar.max_value * 0.50:
			loading_label.text = str(loading_text,"..")
		if progress_bar.value > progress_bar.max_value * 0.75:
			loading_label.text = str(loading_text,"...")
	OddAudioManager.stop()
	progress_bar.value = timer.wait_time - timer.time_left
	
	if init_ui_finished:
		can_proceed = true


func on_timer_timeout():
	if MousePointer.show_mouse_pointer != false:
		MousePointer.disable_mouse_control()
	if ! can_proceed:
		timer.start()
		return
	base_level.queue_free()
	loading_label.hide()
	loading_layer.layer = -1
	get_tree().change_scene_to_packed(GameEvents.splash_intro_sequencer)
	#return
	#var show_controls_screen_instance = show_controls_screen.instantiate()
	#show_controls_screen_instance.closed.connect(on_sound_button_pressed)
	#add_child(show_controls_screen_instance)
	#AudioServer.set_bus_mute(0, false)
	#show_controls_screen_instance.back_button.text = "CONTINUE"


func on_sound_button_pressed():
	get_tree().change_scene_to_packed(GameEvents.splash_intro_sequencer)
