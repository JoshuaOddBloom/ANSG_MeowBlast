extends Node2D

# @tool might be a good option here

@export_enum("Black", "White") var choosen_type: int

#TODO : Add Types as preloads

@onready var animation_player: AnimationPlayer = %AnimationPlayer
#
#func _ready() -> void:
	#match choosen_type:
		#0:
			#print("black")
		#1:
			#print("white")


func play_auto_animation():
	animation_player.play("auto")


func play_out_animation():
	animation_player.play("out")
