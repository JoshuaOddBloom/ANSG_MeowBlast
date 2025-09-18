extends AudioStreamPlayer

class_name RandomAudioStreamPlayer

@export var streams : Array[AudioStream]
@export var randomize_pitch = true
@export var randomize_vol = true
@export var min_volume = -3.0
@export var max_volume = 0.0
@export var min_pitch = 0.9
@export var max_pitch = 1.1


func play_random():
	if streams == null || streams.size() == 0:
		return
	
	if randomize_vol:
		volume_db = randf_range(min_volume, max_volume)
	
	if randomize_pitch:
		pitch_scale = randf_range(min_pitch,max_pitch)
	else:
		pitch_scale = 1
	
	stream = streams.pick_random()
	play()
