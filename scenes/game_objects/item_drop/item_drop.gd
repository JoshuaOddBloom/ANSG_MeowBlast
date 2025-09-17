extends Node2D

@export var item_resource: DroppableItem
@export var fall_speed: float = 30.0
@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var visuals: Node2D = $Visuals
@onready var ring_sprite_2d: Sprite2D = %RingSprite2D
@onready var fire_trail_gpu_particles_2d: GPUParticles2D = %FireTrailGPUParticles2D
@onready var pulsing_gpu_particles_2d: GPUParticles2D = %PulsingGPUParticles2D
@onready var sprite_2d = %Sprite2D

#var item_drop_manager


func _ready():
	$Area2D.area_entered.connect(on_area_entered)
	prints("Item Drop Created - ", name)


func _physics_process(delta: float) -> void:
	global_position.y += fall_speed * delta


func tween_collect(percent: float, start_position: Vector2):
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	#move vial
	global_position = start_position.lerp(player.global_position, percent)
	var direction_from_start = player.global_position - start_position
	
	# interpolate the rotation degrees
	var target_rotation = direction_from_start.angle() #+ deg_to_rad(-90)
	rotation = lerp_angle(rotation, target_rotation, 1 - exp(-2 * get_process_delta_time())) # Frame Rate independant lerp *2


func collect():
	$RandomAudioPlayerComponent.play_random()
	await $RandomAudioPlayerComponent.finished
	#print(item_resource)
	#if item_drop_manager != null:
		#item_drop_manager.collect_upgrade(item_resource)
	Callable(item_drop_collected).call_deferred()
	fire_trail_gpu_particles_2d.emitting = false
	ring_sprite_2d.hide()
	sprite_2d.hide()
	
	# allow time for particle to finish before destroying item
	get_tree().create_timer(fire_trail_gpu_particles_2d.lifetime * 1.1, false).timeout.connect(destroy_item) 


func item_drop_collected():
	GameEvents.emit_item_drop_collected(item_resource.item_name)


func destroy_item():
	print("projectile_destroyed")
	queue_free()


func disable_collision():
	collision_shape_2d.disabled = true


func on_area_entered(_other_area: Area2D):
	if _other_area.is_in_group("level_enemy_bounds"):
		destroy_item()
		return
	
	Callable(disable_collision).call_deferred() # calldefered happens on the next frame
	pulsing_gpu_particles_2d.emitting = false
	var tween = create_tween()
	tween.set_parallel()
	# \ notates a white space line should be a continuation (multi-line code)
	tween.tween_method(tween_collect.bind(global_position), 0.0, 1.0, .5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite_2d, "scale", Vector2.ZERO, .05).set_delay(.45)
	#NOTE: tween_method(passes 'global_position' into 'tween_collect' via .bind(), \goes from 0 to 100 'percent' [0.0, 1.0], runs for 1 second)
	tween.chain() #wait for all previous tweens are finished
	
	tween.tween_callback(collect)


func add_item_resource(new_resource):
	item_resource = new_resource
	Callable(add_properties).call_deferred()


func add_properties():
	if item_resource != null:
		if item_resource.item_modulate_override_color != Color.BLACK:
			visuals.modulate = item_resource.item_modulate_override_color
		fall_speed *= item_resource.item_fall_speed_multiplier
		sprite_2d.texture = item_resource.item_icon
	#var sprite: Sprite2D = get_node_or_null("Sprite")
	#if !is_instance_valid(sprite): # Do we need to create it?
		#sprite = Sprite2D.new()
		#sprite.name = "%Sprite2D"
		## set anything else you need to; position, self_modulate...
		#add_child(sprite)
		
