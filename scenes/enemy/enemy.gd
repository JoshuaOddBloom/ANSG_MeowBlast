extends Node2D


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


var spawn_type: String = ""
var spawn_texture_chosen: Texture = GameEvents.enemy_sprite_idle1
var just_hit: bool = false
var defeated_without_projectile: bool = false
var defeated: bool = false
var lerp_scale_to_global_scale_target: bool = false


func _ready() -> void:
	health_component.defeated.connect(on_defeated)
	hit_box.area_entered.connect(on_hit_box_entered)
	hurt_box.area_entered.connect(on_hurt_box_entered)
	hurt_sprite_timer.timeout.connect(on_hurt_sprite_timer_timeout)
	set_spawn_type()


func _process(delta: float) -> void:
	global_position.y += fall_speed * delta


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
		GameEvents.increment_level(1)
	
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
