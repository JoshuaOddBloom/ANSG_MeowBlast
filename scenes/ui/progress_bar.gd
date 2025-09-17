extends PanelContainer

@export var label_text_override: String = ""
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label

var power_being_used: bool = false

func _ready() -> void:
	#GameEvents.player_power_used.connect(on_player_power_used)
	#GameEvents.player_power_being_used.connect(on_player_power_being_used)
	GameEvents.player_update_power_value.connect(on_player_update_power_value)
	#GameEvents.score_count_changed.connect(on_score_count_changed)
	if label_text_override != "":
		label.text = label_text_override
#
#func reset_progress_bar():
	#label.text = "POWER"
	#progress_bar.value = 0.0

#
#func on_score_count_changed(_score):
	#if power_being_used:
		#return
	#
	#progress_bar.value += progress_bar.max_value
	#prints("progress_bar :", progress_bar.value)

#
#func on_player_power_being_used():
	#power_being_used = true

#
#func on_player_power_used():
	#power_being_used = false
	#reset_progress_bar()


func _on_progress_bar_value_changed(value: float) -> void:
	if value == progress_bar.max_value:
		label.text = "FULLY CHARGED"
	else:
		label.text = "POWER"


func on_player_update_power_value(current_power, power_target):
	progress_bar.max_value = power_target
	progress_bar.value = current_power
