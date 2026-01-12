@tool
extends EditorPlugin

var odd_audio_manager_path: String = "res://addons/odd_audio_manager/odd_audio_manager.tscn"


func _enter_tree() -> void:
	add_autoload_singleton("OddAudioManager", odd_audio_manager_path)


func _exit_tree() -> void:
	#remove_autoload_singleton("OddCameraManager2D")
	remove_autoload_singleton("OddAudioManager")
