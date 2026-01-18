extends HBoxContainer
class_name GameStat

@export var _stat_id: String
@export var _value: Label


func _ready() -> void:
	GameEvents.game_over_stat_update.connect(on_game_over_stat_update)


func on_game_over_stat_update(stat_id: String, new_value):
	if stat_id == _stat_id:
		_value.text = str(new_value)
