extends Node2D

@export var override_reticle_color: bool = false
@export var override_reticle_sprite_color: Color
@export var override_icon: Texture2D
@export var override_icon_scale: bool = false
@export var override_icon_scale_amount: float = 1.0

## Script credit: Game Endeavor (YouTube)
@onready var sprite: Sprite2D = %Sprite
@onready var icon: Sprite2D = %Icon
@onready var marker_2d: Marker2D = %Marker2D
@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var target_position = null
var is_showing : bool = false


func _ready() -> void:
	if override_icon != null:
		icon.texture = override_icon
	if override_icon_scale:
		icon.scale = icon.scale * override_icon_scale_amount
	if override_reticle_color:
		sprite.self_modulate = override_reticle_sprite_color
		
	#GameEvents.player_defeated.connect(func(): visible = false)
	#GameEvents.player_restored.connect(func(): visible = true)


func _process(_delta: float) -> void:
	var canvas = get_canvas_transform()
	var top_left = -canvas.origin / canvas.get_scale()
	var size = get_viewport_rect().size / canvas.get_scale()
	
	set_marker_position(Rect2(top_left, size))
	#set_marker_rotation()


func set_marker_position(bounds : Rect2):
	if target_position == null:
		#sprite.global_position.x = clamp(global_position.x, bounds.position.x, bounds.end.x)
		sprite.global_position.y = clamp(global_position.y, bounds.position.y, bounds.end.y)
	#else:
		#var displacement = global_position - target_position
		#var length
		#
		#var tleft = (bounds.position - target_position).angle()
		#var tright = (Vector2(bounds.end.x, bounds.position.y) - target_position).angle()
		#var bleft = (Vector2(bounds.position.x, bounds.end.y) - target_position).angle()
		#var bright = (bounds.end - target_position).angle()
		#
		#if (displacement.angle() > tleft && displacement.angle()< tright) || (displacement.angle() > bleft && displacement.angle() > bright):
			#var y_length = clamp(displacement.y, bounds.position.y - target_position.y, bounds.end.y - target_position.y)
			#var angle = displacement.anlge() - PI / 2.0
			#length = y_length / cos(angle) if cos(angle) != 0 else y_length
		#else:
			#var x_length = clamp(displacement.x, bounds.position.x - target_position.x, bounds.end.x - target_position.x)
			#var angle = displacement.anlge()
			#length = x_length / cos(angle) if cos(angle) != 0 else x_length
		#
		#sprite.global_position = Vector2(length * cos(displacement.angle()), length * sin(displacement.angle())) + target_position
	
	
	if bounds.has_point(global_position):
		if ! is_showing:
			return
		animation_player.play_backwards("show_reticles")
		is_showing = false
	else:
		if is_showing:
			return
		animation_player.play("show_reticles")
		is_showing = true


func set_marker_rotation():
	if player == null:
		return
	#var angle = (global_position - sprite.global_position).angle()
	var _angle = get_angle_to(player.global_position)
	marker_2d.global_rotation = 0


func set_reticle_color(color):
	## enter "previous" or leave color blank to return to previous color
	if color is Color:
		sprite.self_modulate = color
		return
	if color == null or color == "previous":
		if override_reticle_color:
			sprite.self_modulate = override_reticle_sprite_color
		else:
			sprite.self_modulate = Color.WHITE
		return
