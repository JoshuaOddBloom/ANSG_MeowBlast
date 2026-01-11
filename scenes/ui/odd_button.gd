extends Button

class_name OddButton


@export_category("Options")
@export var is_back_button: bool = false
@export var require_selection_confirmation: bool = false
@export var spawn_menu: bool = false
@export var menu_to_spawn: PackedScene
@export_category("Visuals")
@export var button_icon: Texture2D
@onready var icon_toggleable: Sprite2D = $IconToggleable
@export var icon_toggleable_idle_color = Color(0.0, 0.0, 0.0, 0.5)
@export var icon_toggleable_focused_color = Color(1.0, 1.0, 1.0, 1.0)

@export_category("Audio")
#Audio
@export var play_sound: bool = true
@export var sound_to_play: AudioStream
@onready var random_audio_player_component: RandomAudioStreamPlayer = $RandomAudioPlayerComponent

#var previously_focused_item

func _ready():
	#icon_toggleable.modulate = icon_toggleable_idle_colo
	pressed.connect(on_pressed)


## Focus Action
func _on_focus_entered() -> void:
	#previously_focused_item = self
	icon_toggleable.modulate = icon_toggleable_focused_color


func _on_mouse_entered() -> void:
	if disabled:
		#print("OddButton disabled")
		return
	#previously_focused_item = self
	self.grab_focus()
	icon_toggleable.modulate = icon_toggleable_focused_color


## Unfocus Action
func _on_focus_exited() -> void:
	icon_toggleable.modulate = icon_toggleable_idle_color


func _on_mouse_exited() -> void:
	pass


func on_pressed():
	if random_audio_player_component and play_sound:
		$RandomAudioPlayerComponent.play_random()
		await $RandomAudioPlayerComponent.finished
