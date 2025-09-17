extends CanvasLayer


func _ready():
	GameEvents.player_damaged.connect(on_player_damaged)
	GameEvents.player_defeated.connect(on_player_defeated)
	$AnimationPlayer.play("RESET")


func play_vignette_animation(anim: String):
	$AnimationPlayer.play(anim)

func play_vignette_animation_reversed(anim: String):
	$AnimationPlayer.play_backwards(anim)

func on_player_damaged(_amount): #game loop
	$AnimationPlayer.play("hit")


func on_player_defeated(): 
	$AnimationPlayer.play("defeat_build")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("defeat")
