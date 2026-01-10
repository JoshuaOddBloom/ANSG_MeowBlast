extends GPUParticles2D

@export var particle_number: int

func _ready() -> void:
	if ! GameEvents.given_initial_fire_trail_values:
		## SET INITIAL VALUES FOR GameEvents
		if particle_number == 0:
			GameEvents.initial_fire_trail_particle_lifetime = lifetime
			GameEvents.initial_fire_trail_process_material_scale_min = process_material.scale_min
			GameEvents.initial_fire_trail_process_material_scale_max = process_material.scale_max
			GameEvents.given_initial_fire_trail_values = true
		if particle_number == 1:
			GameEvents.initial_fire_trail_particle_2_lifetime = lifetime
			GameEvents.initial_fire_trail_process_material_2_scale_min = process_material.scale_min
			GameEvents.initial_fire_trail_process_material_2_scale_max = process_material.scale_max
			GameEvents.given_initial_fire_trail_2_values = true
	else:
		## SET VALUES AT RUNTIME FOR PARTICLE
		if particle_number == 0:
			lifetime = GameEvents.initial_fire_trail_particle_lifetime * GameEvents.global_scale_target.x
			process_material.scale_min = GameEvents.initial_fire_trail_process_material_scale_min * GameEvents.global_scale_target.x
			process_material.scale_max = GameEvents.initial_fire_trail_process_material_scale_max * GameEvents.global_scale_target.x
		if particle_number == 1:
			lifetime = GameEvents.initial_fire_trail_particle_2_lifetime * GameEvents.global_scale_target.x
			process_material.scale_min = GameEvents.initial_fire_trail_process_material_2_scale_min * GameEvents.global_scale_target.x
			process_material.scale_max = GameEvents.initial_fire_trail_process_material_2_scale_max * GameEvents.global_scale_target.x
