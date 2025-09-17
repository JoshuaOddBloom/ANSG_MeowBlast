extends Control

@onready var main_menu = preload("res://scenes/ui/main_menu.tscn")
@onready var show_controls_screen = preload("res://scenes/ui/show_controls_screen.tscn")
@onready var timer: Timer = $Timer
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var label: Label = %Label
@onready var color_rect: ColorRect = %ColorRect

func _ready() -> void:
	get_window().grab_focus()
	timer.timeout.connect(on_timer_timeout)
	progress_bar.max_value = timer.wait_time


func _process(_delta: float) -> void:
	if progress_bar.value > progress_bar.max_value * 0.25:
		label.text = "LOADING."
	if progress_bar.value > progress_bar.max_value * 0.50:
		label.text = "LOADING.."
	if progress_bar.value > progress_bar.max_value * 0.75:
		label.text = "LOADING..."
	progress_bar.value = timer.wait_time - timer.time_left


func on_timer_timeout():
	label.hide()
	progress_bar.hide()
	var show_controls_screen_instance = show_controls_screen.instantiate()
	show_controls_screen_instance.closed.connect(on_sound_button_pressed)
	add_child(show_controls_screen_instance)
	show_controls_screen_instance.sound_button.text = "CONTINUE"
	


func on_sound_button_pressed():
	get_tree().change_scene_to_packed(main_menu)
