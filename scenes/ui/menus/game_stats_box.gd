extends VBoxContainer

@export var game_stats: Array[GameStat]

@onready var show_stat_timer: Timer = $ShowStatTimer
@onready var random_audio_stream_player: RandomAudioStreamPlayer = $RandomAudioStreamPlayer

@onready var game_stat_time: GameStat = $Time
@onready var game_stat_threat_level: GameStat = $ThreatLevel
@onready var game_stat_cateroids_defeated: GameStat = $CateroidsDefeated
@onready var game_stat_projectiles: GameStat = $Projectiles
@onready var game_stat_score: GameStat = $Score

var index_to_show: int = 0

func _ready() -> void:
	for game_stat in game_stats:
		if game_stat is GameStat:
			game_stat.modulate = Color.TRANSPARENT
	set_stat_amounts()
	show_stat_timer.timeout.connect(on_show_stat_timer)
	show_stat_timer.start()


func set_stat_amounts():
	game_stat_time._value.text = str(GameEvents.current_time)
	game_stat_threat_level._value.text = str(GameEvents.current_level)
	game_stat_projectiles._value.text = str(GameEvents.projectile_count)
	game_stat_cateroids_defeated._value.text = str(GameEvents.cateroids_defeated)
	game_stat_score._value.text = str(GameEvents.score_count * GameEvents.score_multiplier)


func on_show_stat_timer():
	var stat_to_show = game_stats[index_to_show]
	stat_to_show.modulate = Color.WHITE
	random_audio_stream_player.play_random()
	if index_to_show < len(game_stats)-1:
		index_to_show += 1
		show_stat_timer.start()
