extends Control

signal closed

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var how_to_access_info_label: Label = %HowToAccessInfoLabel
@onready var sound_button: SoundButton = %SoundButton
@onready var bgm_check_button: CheckButton = %BGMCheckButton
@onready var sfx_check_button: CheckButton = %SFXCheckButton


func _ready() -> void:
	button_pressed_values()
	
	sound_button.pressed.connect(on_sound_button_pressed)
	bgm_check_button.toggled.connect(on_bgm_check_button_toggled)
	sfx_check_button.toggled.connect(on_sfx_check_button_toggled)
	sound_button.grab_focus()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		on_sound_button_pressed()


func button_pressed_values():
	var bgm_index = AudioServer.get_bus_index("BGM")
	var sfx_index = AudioServer.get_bus_index("SFX")
	bgm_check_button.button_pressed = ! AudioServer.is_bus_mute(bgm_index)
	sfx_check_button.button_pressed = ! AudioServer.is_bus_mute(sfx_index)


func mute_audio_bus(toggled_on, bus_name):
	# IF TOGGLED ON = TRUE, IS MUTED = FALSE
	var bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_mute(bus_index, ! toggled_on)
	print(bus_name, " Audio Muted")



func on_bgm_check_button_toggled(toggled_on):
	mute_audio_bus(toggled_on, "BGM")


func on_sfx_check_button_toggled(toggled_on):
	mute_audio_bus(toggled_on, "SFX")


func on_sound_button_pressed():
	sound_button.disabled = true
	animation_player.play_backwards("auto")
	await animation_player.animation_finished
	closed.emit()
	queue_free()
