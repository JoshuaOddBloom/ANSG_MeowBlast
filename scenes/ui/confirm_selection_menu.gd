extends MarginContainer

signal confirmation(switch) ## If true, the confirmation was yes

@onready var confirm_selection_no_odd_button: OddButton = %ConfirmSelectionNoOddButton
@onready var confirm_selection_yes_odd_button: OddButton = %ConfirmSelectionYesOddButton

var tween_modulation: Tween

func _ready() -> void:
	confirm_selection_no_odd_button.pressed.connect(_on_confirm_selection.bind(confirm_selection_no_odd_button))
	confirm_selection_yes_odd_button.pressed.connect(_on_confirm_selection.bind(confirm_selection_yes_odd_button))
	
	self.modulate = Color.WHITE
	confirm_selection_no_odd_button.grab_focus()


func _on_confirm_selection(button):
	match button:
		confirm_selection_no_odd_button:
			confirmation.emit(false)
		
		confirm_selection_yes_odd_button:
			confirmation.emit(true)
	
	if tween_modulation:
		tween_modulation.kill()
	
	tween_modulation = create_tween()
	tween_modulation.tween_property(self, "modulate", Color.TRANSPARENT, 0.15)
	tween_modulation.tween_callback(queue_free)
