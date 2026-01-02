extends Node2D
class_name ProjectileScene

@export var projectile_move_speed: int = 800
@export var hurt_damage: int = 1


func _ready() -> void:
	GameEvents.emit_projectile_count_changed(1)
	#GameEvents.emit_score_count_changed(1) # For testing intensity ramping... May need to adjust the min and max delay for enemy spawning


func _process(delta: float) -> void:
	if scale != GameEvents.global_scale_target:
		scale = GameEvents.global_scale_target
	
	if global_position.y <= -500:
		defeated()
	
	# Move Projectile
	position.y -= projectile_move_speed * delta


func defeated():
	GameEvents.emit_projectile_count_changed(-1)
	queue_free()
