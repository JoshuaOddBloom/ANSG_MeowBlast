extends Node

#signal arena_level_increased(arena_level: int)

#const level_INTERVAL = 5

@onready var timer = $Timer

var arena_level = 0


func _ready():
	timer.timeout.connect(on_timer_timeout)

#func _process(_delta):
	#var next_time_target = timer.wait_time - ((arena_level + 1) * level_INTERVAL)
	#if timer.time_left <= next_time_target:
		#arena_level += 1
		#arena_level_increased.emit(arena_level)


func get_time_elapsed():
	return 


func on_timer_timeout():
	return
	#var end_screen_instance = end_screen_scene.instantiate()
	#add_child(end_screen_instance)
	#end_screen_instance.play_jingle()
	#MetaProgression.save()
