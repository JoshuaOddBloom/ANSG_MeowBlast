extends Node2D

signal init_finished

const MAX_FALL_SPEED: float = 115.0
const MAX_ANGRY_FALL_SPEED: float = 135.0

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
@onready var label: Label = $Label
@onready var enemy_sprite_attack_1: Texture = preload("res://scenes/enemy/cateroid_angry_1a.png")
@onready var enemy_sprite_defeated_1: Texture = preload("res://scenes/enemy/cateroid_defeated_1a.png")
@onready var enemy_sprite_hurt_1: Texture = preload("res://scenes/enemy/cateroid_hurt_1c.png")
@onready var enemy_sprite_hurt_2: Texture = preload("res://scenes/enemy/cateroid_hurt_2c.png")
@onready var enemy_sprite_idle_1: Texture = preload("res://scenes/enemy/cateroid_idle_1c.png")
@onready var fire_particles: Node2D = %FireParticles
@onready var fire_trail_gpu_particles_2d_2: GPUParticles2D = %FireTrailGPUParticles2D2
@onready var fire_trail_gpu_particles_2d: GPUParticles2D = %FireTrailGPUParticles2D


var spawn_type: String = ""
var spawn_texture_chosen: Texture = enemy_sprite_idle_1
var just_hit: bool = false
var defeated_without_projectile: bool = false
var defeated: bool = false
var tweening_particle_process_material_scale: bool = false


func _ready() -> void:
	health_component.defeated.connect(on_defeated)
	hit_box.area_entered.connect(on_hit_box_entered)
	hurt_box.area_entered.connect(on_hurt_box_entered)
	hurt_sprite_timer.timeout.connect(on_hurt_sprite_timer_timeout)

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
	## Scale to Global_scale
	if scale != GameEvents.global_scale_target:
		scale = GameEvents.global_scale_target
	
	global_position.y += fall_speed * delta


func set_spawn_type():
	sprite_2d.flip_h = [true, false].pick_random()
	spawn_type = ["default", "sleepy", "angry"].pick_random()
	match spawn_type:
		"default":
			#fall_speed is unchanged, but still needs to be capped
			if fall_speed > MAX_FALL_SPEED:
				fall_speed = MAX_FALL_SPEED
			spawn_texture_chosen = enemy_sprite_idle_1
			
		"sleepy":
			spawn_texture_chosen = enemy_sprite_defeated_1
			fall_speed *= 0.6
			if fall_speed > MAX_FALL_SPEED * 0.6:
				fall_speed = MAX_FALL_SPEED * 0.6
			fire_particles.modulate = Color(0.502, 0.612, 1.0)
			
		"angry":
			spawn_texture_chosen = enemy_sprite_attack_1
			fall_speed *= 1.1
			if fall_speed > MAX_ANGRY_FALL_SPEED:
				fall_speed = MAX_ANGRY_FALL_SPEED
			
	
	
	sprite_2d.texture = spawn_texture_chosen
	label.text = str("fall_speed : ", fall_speed)


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
	var hurt_sprite = [enemy_sprite_hurt_1, enemy_sprite_hurt_2].pick_random()
	sprite_2d.texture = hurt_sprite
	hurt_sprite_timer.start()


func sprite_change_to_defeated():
	sprite_2d.texture = enemy_sprite_defeated_1


func sprite_change_to_idle():
	sprite_2d.texture = spawn_texture_chosen
	just_hit = false


func on_defeated():
	defeated = true
	if defeated_without_projectile:
		pass
	else:
		GameEvents.cateroids_defeated += 1
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
