extends Node



func _ready() -> void:
	pre_compile()


func pre_compile():
	var children = self.get_children()
	for child in children:
		if child.get_child_count() > 1:
			check_for_children(child)
		


func check_for_animations(check_child):
	if check_child is AnimationPlayer:
			var animations_in_player = check_child.get_animation_list()
			for i in animations_in_player:
				#prints("playing - ", check_child, i)
				check_child.play(str(i))


func check_for_children(check_child):
	var children_for_anims = check_child.get_children()
	for i in children_for_anims:
		check_for_animations(i)
