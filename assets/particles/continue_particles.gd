extends GPUParticles2D

@onready var heart_particles: GPUParticles2D = $HeartParticles

func _ready() -> void:
	GameEvents.player_restored.connect(on_player_restored)
	heart_particles.emitting = true
	emitting = true
	visible = true


func on_player_restored():
	heart_particles.emitting = false
	emitting = false
	queue_free()
