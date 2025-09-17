extends Node2D

@onready var bg_animation_player: AnimationPlayer = %BGAnimationPlayer


func _ready() -> void:
	GameEvents.level_changed.connect(on_level_changed)


func on_level_changed(new_level):
	match new_level:
		1:
			bg_animation_player.play("level_1_idle")
		2:
			pass
		3:
			pass
		4:
			pass
		5:
			pass
			
	
