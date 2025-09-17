extends UIIcon
class_name UIHeartContainer

@export var active : bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var restore_added_particles: GPUParticles2D = $RestoreAddedParticles

var heart_is_restore_heart = false


func _ready() -> void:
	#animation_player.play_backwards("depleted")
	pass

#could play an animation when ready to make things pretty
#UI uses this to call the depleated animation and stylishly void a heart
func heart_depleated():
	active = false
	animation_player.play("hit")
	await animation_player.animation_finished
	animation_player.play("depleted")
	await animation_player.animation_finished
	
	print("Freeing Heart...", self)
	queue_free()


func check_if_restore_heart():
	if heart_is_restore_heart:
		animation_player.play("armor")
		restore_added_particles.emitting = true
