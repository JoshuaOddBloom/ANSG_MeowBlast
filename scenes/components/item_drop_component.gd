extends Node
class_name ItemDropComponent

@export_range(0,1) var drop_percent: float = .5
@export var health_component: Node
#@export var item_scene: PackedScene


func _ready():
	(health_component as HealthComponent).defeated.connect(on_defeated)


#if we die, the HealthComponent emits the signal, this vial component does...
func on_defeated():
	var adjusted_drop_percent = drop_percent
	if randf() > adjusted_drop_percent:
		return
	
	if not owner is Node2D and not owner is CharacterBody2D:
		return
	
	GameEvents.emit_item_drop_requested(owner.global_position)
