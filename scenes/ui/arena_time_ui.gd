extends Control


@onready var label = %Label
@onready var timer: Timer = %Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var tell_time: bool = true

func _ready():
	GameEvents.game_paused.connect(on_game_paused)
	GameEvents.player_defeated.connect(on_player_defeated)
	GameEvents.game_over.connect(on_game_over)
	timer.timeout.connect(on_timer_timeout)

func _process(_delta):
	if ! tell_time:
		return
	var time_elapsed = get_elapsed_time()
	label.text = format_seconds_to_string(time_elapsed)


func format_seconds_to_string(seconds: float):
	var minutes = floor(seconds / 60) #floor will lower the var based on how many times it can go into 60, or any value entered
	var remaining_seconds = seconds - (minutes * 60)
	return str("%01d" % minutes) + ":" + ("%02d" % floor(remaining_seconds)) # format string: "%02d" % : Says, i want an int string with two digits, d is int, % what int are we putting in
	#return str(minutes) + ":" + ("%02d" % floor(remaining_seconds)) # format string: "%02d" % : Says, i want an int string with two digits, d is int, % what int are we putting in


func get_elapsed_time():
	return timer.wait_time - timer.time_left


func on_game_paused(occassion):
	if occassion == "upgrading":
		animation_player.play("paused_test")
	elif occassion == "paused":
		animation_player.play("paused")
	elif occassion == "done":
		animation_player.play("RESET")


func on_player_defeated():
	# TODO
	tell_time = false
	timer.stop()


func on_game_over():
	tell_time = false
	timer.stop()


func on_timer_timeout():
	animation_player.play("hit_minute")
