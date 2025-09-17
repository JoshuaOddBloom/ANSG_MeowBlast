extends CanvasLayer

signal transitioned_halfway
signal transition_finished

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var skip_emit = false


func transition():
	animation_player.play("default")
	await transitioned_halfway
	animation_player.play_backwards("default")


func transition_to_scene(scene_path: String):
	transition()
	await transitioned_halfway
	get_tree().change_scene_to_file(scene_path)
	transition_finished.emit()


func emit_transition_halfway():
	get_tree().paused = false
	if skip_emit:
		return
	
	transitioned_halfway.emit()
