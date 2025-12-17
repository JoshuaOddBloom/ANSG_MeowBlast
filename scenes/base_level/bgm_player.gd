extends AudioStreamPlayer

@onready var volume_pitch_tween



func pitch_scale_slide(new_pitch_scale: float, wait_time):
	if volume_pitch_tween:
		volume_pitch_tween.kill()
	volume_pitch_tween = get_tree().create_tween().bind_node(self)
	volume_pitch_tween.parallel().tween_property(self, "pitch_scale", new_pitch_scale, wait_time)
	
