extends Control
class_name ControlsScreen

signal closed

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var how_to_access_info_label: Label = %HowToAccessInfoLabel
#Containers
@onready var instructions_container: VBoxContainer = %InstructionsContainer
@onready var mouse_instructions: PanelContainer = %Mouse
@onready var keyboard_instructions: PanelContainer = %Keyboard
@onready var joypad_instructions: PanelContainer = %Joypad
#Buttons
@onready var back_button: OddButton = %BackButton
@onready var mouse_button: OddButton = %MouseButton
@onready var joypad_button: OddButton = %JoypadButton
@onready var keyboard_button: OddButton = %KeyboardButton
@onready var control_options: VBoxContainer = %ControlOptions

func _ready() -> void:
	back_button.pressed.connect(on_back_button_pressed)
	mouse_button.focus_entered.connect(on_button_focused.bind(mouse_button))
	joypad_button.focus_entered.connect(on_button_focused.bind(joypad_button))
	keyboard_button.focus_entered.connect(on_button_focused.bind(keyboard_button))


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


func on_button_focused(button: OddButton):
	for i in instructions_container.get_children():
		i.hide()
	
	match button:
		mouse_button:
			mouse_instructions.show()
		joypad_button:
			joypad_instructions.show()
		keyboard_button:
			keyboard_instructions.show()
		
