extends Control
class_name ControlsScreen

signal closed

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var how_to_access_info_label: Label = %HowToAccessInfoLabel
@onready var back_button: OddButton = %BackButton


func _ready() -> void:
	back_button.pressed.connect(on_back_button_pressed)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		on_back_button_pressed()


func show_menu():
	animation_player.play("auto")


func back_button_grab_focus():
	back_button.grab_focus()


func on_back_button_pressed():
	back_button.disabled = true
	animation_player.play_backwards("auto")
	await animation_player.animation_finished
	closed.emit()
	queue_free()
