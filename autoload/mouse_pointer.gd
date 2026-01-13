extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var show_mouse_pointer: bool = false


func _ready() -> void:
	GameEvents.player_defeated.connect(func(): Input.mouse_mode = Input.MOUSE_MODE_VISIBLE; sprite_2d.hide())


func _process(_delta: float) -> void:
	if show_mouse_pointer:
		if ! sprite_2d.visible:
			sprite_2d.show()
		if Input.mouse_mode != Input.MOUSE_MODE_CONFINED_HIDDEN:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		
		sprite_2d.global_position = get_global_mouse_position()
		
	else:
		if sprite_2d.visible:
			sprite_2d.hide()
		
		if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("pause"):
		disable_mouse_control()


func activate_mouse_controls():
	show_mouse_pointer = true
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN


func disable_mouse_control():
	show_mouse_pointer = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
