extends Control

@export var main_menu: PackedScene
@onready var segment_container: Control = %SegmentContainer
@onready var time_between_segments_timer: Timer = %TimeBetweenSegmentsTimer

var current_segment_index: int = 0


func _ready() -> void:
	MousePointer.disable_mouse_control()
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	OddAudioManager.stop_playing_pitch_down(0.3)
	time_between_segments_timer.timeout.connect(on_time_between_segments_timer_timeout)
	for segment in segment_container.get_children():
		if segment is SplashIntroSeqment:
			segment.hide()
			segment.splash_segment_finished.connect(func(): time_between_segments_timer.start())
	
	time_between_segments_timer.start()


func on_time_between_segments_timer_timeout():
	prints("timer finished", current_segment_index)
	play_segment()
	current_segment_index += 1


func play_segment():
	if current_segment_index > (len(segment_container.get_children())-1):
		open_main_menu() 
	else:
		var segment_to_play = segment_container.get_child(current_segment_index) as SplashIntroSeqment
		segment_to_play.show()
		segment_to_play.start()


func open_main_menu():
	get_tree().change_scene_to_packed(main_menu)
