extends Timer

func _on_timeout() -> void:
	var item_comp = $"../ItemDropComponent" as ItemDropComponent
	item_comp.on_defeated()
