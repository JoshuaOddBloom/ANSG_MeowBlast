extends Button

class_name SoundButton

signal sound_finished

@onready var icon_toggleable: Sprite2D = $IconToggleable

var icon_toggleable_idle_color = Color(0.0, 0.0, 0.0, 0.5)
var icon_toggleable_focused_color = Color(1.0, 1.0, 1.0, 1.0)

#var previously_focused_item

func _ready():
	#icon_toggleable.modulate = icon_toggleable_idle_color
	pressed.connect(on_pressed)


## Focus Action
func _on_focus_entered() -> void:
	#previously_focused_item = self
	icon_toggleable.modulate = icon_toggleable_focused_color


func _on_mouse_entered() -> void:
	if disabled:
		#print("soundbutton disabled")
		return
	#previously_focused_item = self
	self.grab_focus()
	icon_toggleable.modulate = icon_toggleable_focused_color


## Unfocus Action
func _on_focus_exited() -> void:
	icon_toggleable.modulate = icon_toggleable_idle_color


func _on_mouse_exited() -> void:
	pass
	#icon_toggleable.modulate = icon_toggleable_idle_color


func on_pressed():
	$RandomAudioPlayerComponent.play_random()
	await $RandomAudioPlayerComponent.finished
	sound_finished.emit()
