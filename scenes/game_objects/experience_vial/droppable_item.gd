extends Node2D


@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D
@onready var fire_trail_gpu_particles_2d: GPUParticles2D = $ConstantGPUParticles2D
@onready var pulsing_gpu_particles_2d: GPUParticles2D = $PulsingGPUParticles2D
@onready var target_reticles: Node2D = %TargetReticles
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
#@onready var camera_focus_gizmo: CameraFocusGizmo = $CameraFocusGizmo


func _ready():
	$Area2D.area_entered.connect(on_area_entered)

func tween_collect(percent: float, start_position: Vector2):
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	#camera_focus_gizmo.play_hide_with_fade_animation()
	
	#move item
	global_position = start_position.lerp(player.global_position, percent)
	var direction_from_start = player.global_position - start_position
	
	# interpolate the rotation degrees
	var target_rotation = direction_from_start.angle() #+ deg_to_rad(-90)
	rotation = lerp_angle(rotation, target_rotation, 1 - exp(-2 * get_process_delta_time())) # Frame Rate independant lerp *2


func collect():
	$CameraFocusGizmo.queue_free()
	$RandomAudioPlayerComponent.play_random()
	await $RandomAudioPlayerComponent.finished
	GameEvents.emit_experience_vial_collected(1)
	gpu_particles_2d.emitting = false
	get_tree().create_timer(fire_trail_gpu_particles_2d.lifetime * 1.1, false).timeout.connect(destroy_item)


func destroy_item():
	queue_free()


func disable_collision():
	collision_shape_2d.disabled = true


func on_area_entered(_other_area: Area2D):
	# We need to disable the collision shape to keep it from missing collisions with the player and stopping the existing tween
	# # Collision shapes cannot be modified within a physics callback
	# # so we need to do so in a method. This is how we call it
	
	Callable(disable_collision).call_deferred() # calldefered happens on the next frame
	fire_trail_gpu_particles_2d.emitting = false
	pulsing_gpu_particles_2d.emitting = false
	var tween = create_tween()
	tween.set_parallel()
	# \ notates a white space line should be a continuation (multi-line code)
	tween.tween_method(tween_collect.bind(global_position), 0.0, 1.0, 0.5)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_BACK)
	tween.tween_property(gpu_particles_2d, "modulate", Color.TRANSPARENT, 0.75)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.05).set_delay(0.45)
	#NOTE: tween_method(passes 'global_position' into 'tween_collect' via .bind(), \goes from 0 to 100 'percent' [0.0, 1.0], runs for 1 second)
	tween.chain() #wait for all previous tweens are finished
	
	tween.tween_callback(collect)
