extends Control

@export var splash_intro_segments: Array[PackedScene]
@export var main_menu: PackedScene
@onready var time_between_segments_timer: Timer = %TimeBetweenSegmentsTimer

var current_segment_index: int = 0

func _ready() -> void:
	time_between_segments_timer.timeout.connect(on_time_between_segments_timer_timeout)
	for segment in splash_intro_segments:
		if segment == SplashIntroSeqment:
			segment.splash_segment_finished.connect(func(): time_between_segments_timer.start())
	
	play_segment()


func on_time_between_segments_timer_timeout():
	current_segment_index += 1
	play_segment()


func play_segment():
	
	
	splash_intro_segments[current_segment_index].start()


func open_main_menu():
	get_tree().change_scene_to_packed(main_menu)
