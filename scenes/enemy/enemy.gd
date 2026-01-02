extends Node2D

signal init_finished

@export var increment_progress_value: int = 1
@export var fall_speed: float = 40.0
@export var hurt_damage: int = 1
# SYS
@onready var hit_box: Area2D = %HitBox
@onready var hurt_box: Area2D = %HurtBox
@onready var health_component: Node = $HealthComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurt_sprite_timer: Timer = %HurtSpriteTimer
# VISUAL
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var fire_trail_gpu_particles_2d_2: GPUParticles2D = %FireTrailGPUParticles2D2
@onready var fire_trail_gpu_particles_2d: GPUParticles2D = %FireTrailGPUParticles2D
@onready var process_material = fire_trail_gpu_particles_2d.process_material as ParticleProcessMaterial
@onready var process_material_2 = fire_trail_gpu_particles_2d_2.process_material as ParticleProcessMaterial


var spawn_type: String = ""
var spawn_texture_chosen: Texture = GameEvents.enemy_sprite_idle1
var just_hit: bool = false
var defeated_without_projectile: bool = false
var defeated: bool = false
var tweening_particle_process_material_scale: bool = false

var initial_particle_process_material_scale_min: float = 0.0
var initial_particle_process_material_2_scale_min: float = 0.0
var initial_particle_process_material_scale_max: float = 0.0
var initial_particle_process_material_2_scale_max: float = 0.0
var initial_fire_trail_gpu_particles_2d_lifetime: float = 0.0
var initial_fire_trail_gpu_particles_2d_2_lifetime: float = 0.0


func _ready() -> void:
	health_component.defeated.connect(on_defeated)
	hit_box.area_entered.connect(on_hit_box_entered)
	hurt_box.area_entered.connect(on_hurt_box_entered)
	hurt_sprite_timer.timeout.connect(on_hurt_sprite_timer_timeout)
	
	initial_particle_process_material_scale_min = process_material.scale_min
	initial_particle_process_material_2_scale_min = process_material_2.scale_min
	initial_particle_process_material_scale_max = process_material.scale_max
	initial_particle_process_material_2_scale_max = process_material_2.scale_max
	initial_fire_trail_gpu_particles_2d_lifetime = fire_trail_gpu_particles_2d.lifetime
	initial_fire_trail_gpu_particles_2d_2_lifetime = fire_trail_gpu_particles_2d_2.lifetime
	
	if process_material.scale_max != GameEvents.global_scale_target.x or process_material_2.scale_max != GameEvents.global_scale_target.x:
		# set process_material values
		fire_trail_gpu_particles_2d.lifetime = initial_fire_trail_gpu_particles_2d_lifetime * GameEvents.global_scale_target.x
		process_material.scale_min = initial_particle_process_material_scale_min * GameEvents.global_scale_target.x
		process_material.scale_max = initial_particle_process_material_scale_max * GameEvents.global_scale_target.x
		
		# set process_material_2 values
		fire_trail_gpu_particles_2d_2.lifetime = initial_fire_trail_gpu_particles_2d_2_lifetime * GameEvents.global_scale_target.x
		process_material_2.scale_min = initial_particle_process_material_2_scale_min * GameEvents.global_scale_target.x
		process_material_2.scale_max = initial_particle_process_material_2_scale_max * GameEvents.global_scale_target.x

	set_spawn_type()


func init():
	var animation_list = animation_player.get_animation_list()
	for anim in animation_list:
		var original_loop_mode = animation_player.get_animation(anim).get_loop_mode()
		animation_player.get_animation(anim).set_loop_mode(Animation.LOOP_NONE)
		
		animation_player.play(anim)
		await animation_player.animation_finished
		animation_player.get_animation(anim).set_loop_mode(original_loop_mode)
		
	animation_player.play("RESET")
	init_finished.emit()


func _process(delta: float) -> void:
	if scale != GameEvents.global_scale_target:
		scale = GameEvents.global_scale_target
		
		# TODO - for the luv of bloom PLEASE figure out a mathematical solution to this
		
		
		if process_material and process_material_2:
			if process_material.scale_max != GameEvents.global_scale_target.x or process_material_2.scale_max != GameEvents.global_scale_target.x:
				if GameEvents.global_scale_tweening:
					if ! tweening_particle_process_material_scale:
						tweening_particle_process_material_scale = true
				
		
		# tween the particles' scale values and lifetime
		if tweening_particle_process_material_scale and GameEvents.global_scale_tweening:
			var process_material_tween = get_tree().create_tween().parallel()
			process_material_tween.tween_property(process_material, "scale_max", (initial_particle_process_material_scale_max * GameEvents.global_scale_target).x, 10)
			process_material_tween.tween_property(process_material, "scale_min", (initial_particle_process_material_scale_max * GameEvents.global_scale_target).x, 10)
			process_material_tween.tween_property(process_material_2, "scale_max", (initial_particle_process_material_2_scale_max * GameEvents.global_scale_target).x, 10)
			process_material_tween.tween_property(process_material_2, "scale_min", (initial_particle_process_material_2_scale_max * GameEvents.global_scale_target).x, 10)
			process_material_tween.tween_property(fire_trail_gpu_particles_2d, "lifetime", (initial_fire_trail_gpu_particles_2d_lifetime * GameEvents.global_scale_target).x, 10)
			process_material_tween.tween_property(fire_trail_gpu_particles_2d_2, "lifetime", (initial_fire_trail_gpu_particles_2d_2_lifetime * GameEvents.global_scale_target).x, 10)
			process_material_tween.chain()
			process_material_tween.tween_callback(func(): tweening_particle_process_material_scale = false)
		
		# Tween?
		#if process_material and process_material_2:
			#var process_material_tween = get_tree().create_tween()
			#process_material_tween.tween_property(process_material, "scale_max", (process_material.scale_max * GameEvents.global_scale_target).x, 3)
			#process_material_tween.tween_property(process_material_2, "scale_max", (process_material_2.scale_max * GameEvents.global_scale_target).x, 3)
			
			#process_material.scale_max = lerpf(process_material.scale_max, (process_material.scale_max * GameEvents.global_scale_target).x, 1.0)
		#prints(process_material.scale_max, process_material_2.scale_max, GameEvents.global_scale_target)
	
	global_position.y += fall_speed * delta


#func change_particle_sizes():
	#var process_material = fire_trail_gpu_particles_2d.process_material as ParticleProcessMaterial
	#var process_material_2 = fire_trail_gpu_particles_2d_2.process_material as ParticleProcessMaterial
		
		# Lerp?
		#process_material.scale_max = lerp(process_material.scale_max, process_material.scale_max * .1, 1.0)


func set_spawn_type():
	sprite_2d.flip_h = [true, false].pick_random()
	spawn_type = ["default", "sleepy", "angry"].pick_random()
	match spawn_type:
		"default":
			#fall_speed is unchanged
			spawn_texture_chosen = GameEvents.enemy_sprite_idle1
			
		"sleepy":
			spawn_texture_chosen = GameEvents.enemy_sprite_defeated1
			fall_speed *= 0.6
			
		"angry":
			spawn_texture_chosen = GameEvents.enemy_sprite_attack1
			fall_speed *= 1.1
			
	
	sprite_2d.texture = spawn_texture_chosen


func on_hurt_sprite_timer_timeout():
	if defeated:
		return
	if just_hit:
		just_hit = false
	sprite_change_to_idle()


func take_damage(amount):
	just_hit = true
	sprite_change_to_hurt()
	health_component.take_damage(amount)


func sprite_change_to_hurt():
	var hurt_sprite = [GameEvents.enemy_sprite_hurt1, GameEvents.enemy_sprite_hurt2].pick_random()
	sprite_2d.texture = hurt_sprite
	hurt_sprite_timer.start()


func sprite_change_to_defeated():
	sprite_2d.texture = GameEvents.enemy_sprite_defeated1


func sprite_change_to_idle():
	sprite_2d.texture = spawn_texture_chosen
	just_hit = false


func on_defeated():
	defeated = true
	if defeated_without_projectile:
		pass
	else:
		GameEvents.emit_score_count_changed(1)
		GameEvents.increment_level(increment_progress_value)
	
	fall_speed = 5.0
	animation_player.play("defeated")


func on_hit_box_entered(area: Area2D):
	if area.owner.is_in_group("projectile"):
		take_damage(area.owner.hurt_damage)
		area.owner.defeated()
	
	if area.is_in_group("level_enemy_bounds"):
		GameEvents.emit_player_damaged(hurt_damage)
		defeated_without_projectile = true
		take_damage(health_component.current_health)


func on_hurt_box_entered(area: Area2D):
	if area.owner.is_in_group("player"):
		GameEvents.emit_player_damaged(hurt_damage)
		defeated_without_projectile = true
		take_damage(health_component.current_health)
