extends Resource
class_name DroppableItem

@export var item_name: String
@export var item_icon: Resource
@export var item_modulate_override_color: Color = Color.BLACK
@export var item_weight: int = 10 ## The higher this number, the more likely it is to spawn
@export var item_fall_speed_multiplier: float = 1.0
@export var add_icon_to_ui: bool = true
@export var max_quantity: int = 0
