extends Node

@export_range(0,1) var drop_percent: float = 0.5
@export var item_base = preload("res://scenes/game_objects/item_drop/item_drop.tscn")
const ITEM_HEALTH_UP = preload("res://resources/items/item_health_up.tres")
@export var droppable_items: Array[DroppableItem]
@onready var entities_layer: Node2D = %EntitiesLayer


var item_pool : WeightedTable = WeightedTable.new()
var current_items = {}


func _ready() -> void:
	GameEvents.item_drop_requested.connect(on_item_drop_requested)
	#GameEvents.item_drop_collected.connect(on_item_drop_collected)
	add_droppable_items_to_item_pool()


func add_droppable_items_to_item_pool():
	for i in droppable_items:
		if i == null:
			return
		
		item_pool.add_item(i, i.item_weight)
		print("item added ", i.item_name)
	
	prints("item_pool", item_pool)


func on_item_drop_requested(given_location):
	
	var adjusted_drop_percent = drop_percent
	if randf() > adjusted_drop_percent:
		return
	
	var item_chosen

	if GameEvents.player_at_max_health:
		item_chosen = pick_items([ITEM_HEALTH_UP])
	else:
		item_chosen = pick_items([])
	
	var item_instance = item_base.instantiate()
	call_deferred("create_item_instance", item_instance)
	item_instance.add_item_resource(item_chosen)
	
	
	#item_instance.item_resource = item_chosen
	print(item_instance.item_resource)
	prints("item chosen", item_chosen)
	item_instance.global_position = given_location
	
	#Callable(entities_layer.add_child(item_instance)).call_deferred()
	
	#item_chosen


func create_item_instance(instance):
	entities_layer.add_child(instance)


#func on_item_drop_collected(item: DroppableItem):####
	#apply_item(item)


func apply_item(item: DroppableItem):
	## For item selection process
	## Pull from item list
	var has_item = current_items.has(item.item_name)
	if !has_item:
		current_items[item.item_name] = { #create a new object at the key
			"resource": item, #has a reference of the resource
			"quantity": 1 #only 1
		}
		if item.add_icon_to_ui:
			GameEvents.emit_ui_add_item_icon(item.item_name, item.icon, item.name)
	else:
		current_items[item.item_name]["quantity"] += 1
		if item.add_icon_to_ui:
			GameEvents.emit_ui_increment_item_count(item.item_name, false)
	
	#filter the item pool
	if item.max_quantity > 0:
		var current_quantity =  current_items[item.item_name]["quantity"]
		if current_quantity == item.max_quantity:
			GameEvents.emit_ui_increment_item_count(item.item_name, true)
			item_pool.remove_item(item)
	
	update_item_pool(item)
	#Tell the GameEvents autoload send out the ability_item_added signal to all listeners
	GameEvents.emit_ability_item_added(item, current_items)
	#we then need to connect the signal insitem_name the abilities we create


func update_item_pool(_chosen_item: DroppableItem):
	return


func pick_items(items_to_exclude: Array[DroppableItem]): #called in on_level_up()
	return item_pool.pick_item(items_to_exclude) # housed in the Weighted Table script
