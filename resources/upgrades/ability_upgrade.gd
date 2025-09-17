extends Resource
class_name AbilityUpgrade

# Attach this Script to an Ability Upgrade resource
@export var id: String
@export var max_quantity: int
@export var icon : Texture2D = preload("res://assets/textures/16x16sqr_yellow.png")
@export var name : String
@export var add_icon_to_ui : bool
@export_multiline var description: String
