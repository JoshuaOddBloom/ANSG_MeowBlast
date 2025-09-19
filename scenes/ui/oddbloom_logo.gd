extends Node2D

# @tool might be a good option here

@export_enum("White") var choosen_type: int

#TODO : Add Types as preloads

@onready var odd_bloom_logo_animation_player: AnimationPlayer = %OddBloomLogoAnimationPlayer


#
#func _ready() -> void:
	#match choosen_type:
		#0:
			##print("black")
		#1:
			##print("white")


func play_auto_animation():
	odd_bloom_logo_animation_player.play("auto")
	await odd_bloom_logo_animation_player.animation_finished
	
	queue_free()


func play_out_animation():
	odd_bloom_logo_animation_player.play("out")
