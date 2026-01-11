extends Node2D

@export var particle_effects: Array[ParticleProcessMaterial]


func init() -> void:
	load_cache()


func load_cache():
	for effect in particle_effects:
		var particle_instance : GPUParticles2D = GPUParticles2D.new()
		particle_instance.process_material = effect
		particle_instance.one_shot = true
		particle_instance.emitting = true
		add_child(particle_instance)
