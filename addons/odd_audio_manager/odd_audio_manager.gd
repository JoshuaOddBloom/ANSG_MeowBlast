extends AudioStreamPlayer

signal request_bgm_streams
signal request_player_death_stream
signal request_restart_impact_stream
signal audio_stopped
signal audio_started

const MINIMUM_PITCH_SCALE: float = 0.01
const MAXIMUM_PITCH_SCALE: float = 2.0
const MINIMUM_VOLUME: float = -80.0
const MAXIMUM_VOLUME: float = 0.0


## NOTE: Set as export for easy debugging, but not assigned via the editor
@export var debug = false
@export_group("For Debugging - do not assign here")
@export var stream_queue : Array = [] ## Held by the Root Scenes (Stage / Main / Mode / Menu)
@export var death_bgm_stream : Resource ## Held by the Player
@export_range(-80.0, 0) var restart_impact_volume : float

@export_category("Modifiers")

var manager_volume: float = 0.0 :
	set(value):
		manager_volume = linear_to_db(value)
		volume_db = manager_volume

@export_range(MINIMUM_PITCH_SCALE, MAXIMUM_PITCH_SCALE) var manager_pitch_scale: float = 1.0 :
	set(value):
		manager_pitch_scale = value
		pitch_scale = manager_pitch_scale

@export var reset_volume_and_pitch_on_play: bool = false
@export var background_music_bus: String = "BGM"
@export var sound_effects_bus: String = "SFX"

@onready var restart_impact_player: AudioStreamPlayer = $RestartImpact
@onready var death_bgm_player: AudioStreamPlayer = %DeathBGM

@onready var stream_to_play = 0
@onready var stop_playing_pitch_down_tween
@onready var start_playing_fade_tween
@onready var tween_manager_pitch_scale_tween

# Audio Effects (May swap for Resources instead of scenes. Not sure yet.)
@onready var empty_audio_effect: CustomAudioEffectRack = %EmptyAudioEffectRack
@onready var pause_audio_effect: CustomAudioEffectRack = %PauseAudioEffectRack
@onready var upgrading_audio_effect: CustomAudioEffectRack = %UpgradingAudioEffectRack
@onready var stop_reverb_audio_effect: CustomAudioEffectRack = %StopReverbAudioEffectRack

var bgm_restart_position = 0.0
var pitch_tween: Tween


#TODO : Uncouple the GameEvents Autoload signals from AudioManager. There is no reason to have to couple them together (i think)
#TODO : Figure out what's going on with the Audio Effects
#TODO : Add an audio effect for stopping the audio and having a reverb tail


func _ready():
	load_save_data()
	GameEvents.game_ended.connect(on_game_over)
	#TODO NEED TO MAKE THESE INDEPENDANT
	
	#TODO ALLOW TIE INS FOR MENUS WITHOUT THE NEED FOR THEM
	#Options.audio_bus_toggled_on.connect(on_options_audio_bus_toggled_on)
	#Options.audio_slider_changed.connect(on_options_audio_slider_changed)
	
	# BUG THESE SHOULD HAVE NEVER BEEN SIGNAL CALLS TO BEGIN WITH. 
	#	NEED TO FIX IN RECURSOR IF I CONTINUE IN GODOT
	#GameEvents tie-in
	#GameEvents.hard_reset.connect(on_hard_reset)
	#GameEvents.bgm_restore.connect(on_bgm_restore)
	#GameEvents.bgm_apply_effect.connect(on_bgm_apply_effect)
	#GameEvents.game_paused.connect(on_game_paused)
	
	restart_impact_player.volume_db = restart_impact_volume
	stop_playing()
	request_player_death_stream.emit()
	#request_streams()
	play_next_stream()


func load_save_data():
	
	for i in AudioServer.bus_count:
		#var audio_bus_channels = AudioServer.get_bus_channels(i)
		print("AudioManager : Bus Found : ", AudioServer.get_bus_name(i))
	
	#AudioServer.set_bus_mute("BGM", Options.save_data["audio_data"]["bgm_toggled_on"])
	
	#TODO NEED TO MAKE THESE INDEPENDANT
	#set_bus_mute(Options.save_data["audio_data"]["bgm_toggled_on"], "BGM")
	#set_bus_mute(Options.save_data["audio_data"]["sfx_toggled_on"], "SFX")
	#
	#set_bus_volume("BGM", Options.save_data["audio_data"]["bgm_slider_amount"])
	#set_bus_volume("SFX", Options.save_data["audio_data"]["sfx_slider_amount"])
	#
	#print("AudioManager : BGM value : ", Options.save_data["audio_data"]["bgm_slider_amount"])
	#print("AudioManager : SFX value : ", Options.save_data["audio_data"]["sfx_slider_amount"])


func on_options_audio_bus_toggled_on(toggled_on, bus_name):
	set_bus_mute(toggled_on, bus_name)


func on_options_audio_slider_changed(value, bus_name):
	set_bus_volume(bus_name, value)


func on_game_over():
	if pitch_tween:
		pitch_tween.kill()
	pitch_tween = get_tree().create_tween()
	pitch_tween.tween_property(self, "pitch_scale", 0.42, 0.4)


func set_bus_mute(bus_name, mute): ## Passes the bus name and mute boolean to the Audio Server
	var bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_mute(bus_index, mute)


func set_bus_volume(bus_name, value):
	var bus_index = AudioServer.get_bus_index(bus_name)
	#prints("bus_index", bus_index)
	var new_bus_volume_db = linear_to_db(value)
	#print(AudioServer.get_bus_name(1))
	AudioServer.set_bus_volume_db(bus_index, new_bus_volume_db)
	# BUG VOLUME CHANGING NOT WORKING FROM SOUNDTESTINGSCREEN VOLUME CHANGED FUNCTION


func on_game_paused(occassion):
	if occassion == "paused":
		apply_sfx(pause_audio_effect)
	
	if occassion == "upgrading":
		apply_sfx(upgrading_audio_effect)


func apply_sfx(audio_effect_rack):
	var bus_index = self.get_index()
	
	# 
	if audio_effect_rack.slot1 != null:
		AudioServer.add_bus_effect(bus_index, audio_effect_rack.slot1, 0)
	if audio_effect_rack.slot2 != null:
		AudioServer.add_bus_effect(bus_index, audio_effect_rack.slot2, 1)
	if audio_effect_rack.slot3 != null:
		AudioServer.add_bus_effect(bus_index, audio_effect_rack.slot3, 2)
	if audio_effect_rack.slot4 != null:
		AudioServer.add_bus_effect(bus_index, audio_effect_rack.slot4, 3)
	if audio_effect_rack.slot5 != null:
		AudioServer.add_bus_effect(bus_index, audio_effect_rack.slot5, 4)
	if audio_effect_rack.slot6 != null:
		AudioServer.add_bus_effect(bus_index, audio_effect_rack.slot6, 5)
	if audio_effect_rack.slot7 != null:
		AudioServer.add_bus_effect(bus_index, audio_effect_rack.slot7, 6)
	if audio_effect_rack.slot8 != null:
		AudioServer.add_bus_effect(bus_index, audio_effect_rack.slot8, 7)
	if audio_effect_rack.slot9 != null:
		AudioServer.add_bus_effect(bus_index, audio_effect_rack.slot9, 8)


func remove_sfx():
	var bus_index = self.get_index()
	var effect_count = AudioServer.get_bus_effect_count(bus_index)
	
	for i in effect_count:
		AudioServer.remove_bus_effect(bus_index,0)


func request_streams():
	## Ask all sources for streams
	request_bgm_streams.emit()
	request_player_death_stream.emit()
	request_restart_impact_stream.emit()


func hard_reset():
	clear_streams()


func bgm_restore():
	## Not a full reset, but more of a resart for the player
	#IF PLAYER RESTORE/RETRY vs RESTART
	bgm_restore_from_stopped()


func reset_vol_and_pitch():
	volume_db = 0.0
	pitch_scale = 1.0
	return
	
	# Why is all of this down here?
	
	if manager_volume != 0.0:
		volume_db = manager_volume
	else:
		volume_db = 0.0
	
	if manager_pitch_scale != 1.0:
		if manager_pitch_scale < MINIMUM_PITCH_SCALE:
			#the manager_pitch_scale has gone way down
			manager_pitch_scale = MINIMUM_PITCH_SCALE
		
		pitch_scale = manager_pitch_scale
	else:
		pitch_scale = 1.0


func play_next_stream():
	if reset_volume_and_pitch_on_play:
		reset_vol_and_pitch()
	
	if debug: print("AudioManager.play_next_stream() : Streams Queue : ", stream_queue)
	if len(stream_queue) <= 0:
		if debug: print("AudioManager.play_next_stream() : No streams to play")
		return
	
	stream = stream_queue[stream_to_play]
	if debug: print("AudioManager.play_next_stream() : Now Playing stream ", stream_to_play, " : ", stream)
	play()
	audio_started.emit()


func set_death_bgm_stream(new_death_bgm_stream : Resource):
	## Called by the Player's _ready function
	if new_death_bgm_stream == null:
		if debug: print("\n!!! AudioManager.set_death_bgm_stream : No new death bgm stream provided\n")
		return
	death_bgm_stream = new_death_bgm_stream
	death_bgm_player.stream = death_bgm_stream
	if debug: print("AudioManager.set_death_bgm_stream : death bgm player.stream : ", death_bgm_player.stream)


func set_restart_impact_stream(new_restart_impact_stream : Resource):
	if new_restart_impact_stream == null:
		if debug: print("\n!!!AudioManager.set_restart_impact_stream : No restart impact stream provided\n")
		return
	restart_impact_player.stream = new_restart_impact_stream


func add_to_bgm_streams(new_stream_queue : Array):
	stop_playing()
	clear_streams()
	
	if new_stream_queue == null:
		return
	
	if debug:
		print("AudioManager.add_to_bgm_streams : Incoming Streams : ", len(new_stream_queue))
		print(new_stream_queue)
	stream_queue.append_array(new_stream_queue) 
	
	if debug:
		print("AudioManager.add_to_bgm_streams : Previous Queue Emptied")
		print("AudioManager.add_to_bgm_streams : Streams Added to Queue : ", stream_queue)


func clear_streams():
	stream_to_play = 0
	stream_queue = []


func _on_finished() -> void:
	if debug:
		print((len(stream_queue) -1), ">", stream_to_play)
		print("Running play_next_stream()...")
	
	if (len(stream_queue) -1) > stream_to_play:
		stream_to_play += 1
	play_next_stream()


func play_death_sound():
	death_bgm_player.volume_db = -6.0
	death_bgm_player.pitch_scale = 0.68
	#death_bgm_player.stream = death_bgm_stream
	death_bgm_player.play()


func stop_playing(audio_stream_player = self):
	bgm_restart_position = get_playback_position() ############# Last edit
	if debug: prints("AudioManager.stop_playing : bgm_restart_position = SAVED AS :", bgm_restart_position)
	if debug: print("AudioManager.stop_playing : Audio Stopped")
	
	if audio_stream_player != self:
		audio_stream_player.stop()
		if debug: print("AudioManager.stop_playing : Stopped Audio Player : ", audio_stream_player)
		return
	
	
	if stop_playing_pitch_down_tween:
		stop_playing_pitch_down_tween.kill()
	
	stop()
	
	if reset_volume_and_pitch_on_play:
		reset_vol_and_pitch()
	
	audio_stopped.emit()


func bgm_restore_from_stopped(resume_with_pitch: bool = false):####### Potentially use tween
	print("AudioManager.bgm_restore_from_stopped : bgm_restart_position : ", bgm_restart_position)
	
	
	prints("BGMPOSITION", bgm_restart_position)
	if bgm_restart_position > 0.0:
		play(bgm_restart_position)
		
		if resume_with_pitch:
			start_playing_with_pitch()
		else:
			start_playing_with_fade_in()
	else:
		play_next_stream()


func stop_playing_pitch_down(time : float = 3.0):
	var pitch_cache = pitch_scale
	if debug: 
		prints("pitch_cache", pitch_cache)
		print("AudioManager.stop_playing_pitch_down : Stopping audio with pitch : ")
	
	if stop_playing_pitch_down_tween:
		stop_playing_pitch_down_tween.kill()
	
	stop_playing_pitch_down_tween = get_tree().create_tween().bind_node(self)
	
	stop_playing_pitch_down_tween.parallel().tween_property(self, "volume_db", .5, time).set_ease(Tween.EASE_IN)
	stop_playing_pitch_down_tween.parallel().tween_property(self, "pitch_scale", MINIMUM_PITCH_SCALE, time).set_ease(Tween.EASE_IN)
	
	stop_playing_pitch_down_tween.chain().tween_property(self, "volume_db", MINIMUM_VOLUME, time)
	stop_playing_pitch_down_tween.chain().parallel().tween_property(self, "pitch_scale", MINIMUM_PITCH_SCALE, time/2.0)
	stop_playing_pitch_down_tween.chain().tween_callback(stop_playing)
	
	#stop_playing_pitch_down_tween.chain().tween_callback(stop_playing)
	#reset_vol_and_pitch()


func start_playing_immediately():
	pass


func start_playing_with_fade_in(time : float = .5):
	if start_playing_fade_tween:
		start_playing_fade_tween.kill()
	if stop_playing_pitch_down_tween:
		stop_playing_pitch_down_tween.kill()
	
	var volume_target: float = manager_volume
	volume_db = MINIMUM_VOLUME
	
	if debug: 
		print("AudioManager.start_playing_fade : Starting audio (with fade)")
		print("VOLUMETARGET:", volume_target)
	
	start_playing_fade_tween = get_tree().create_tween().bind_node(self)
	start_playing_fade_tween.parallel().tween_property(self, "volume_db", volume_target, time).set_ease(Tween.EASE_OUT)
	#start_playing_fade_tween.parallel().tween_property(death_bgm_player, "volume_db", -80, time*2.0).set_ease(Tween.EASE_OUT)
	

func start_playing_with_pitch(time : float = 0.5, use_manager_pitch_scale: bool = true, pitch_target_override: float = 1.0):
	if debug: print("AudioManager.start_playing_fade : Starting audio (with fade)")
	
	if start_playing_fade_tween:
		start_playing_fade_tween.kill()
	
	start_playing_fade_tween = get_tree().create_tween().bind_node(self)
	start_playing_fade_tween.parallel().tween_property(self, "volume_db", 0.0, time/2.0).set_ease(Tween.EASE_OUT_IN)
	start_playing_fade_tween.parallel().tween_property(death_bgm_player, "volume_db", -80, time*2.0).set_ease(Tween.EASE_OUT)
	if use_manager_pitch_scale:
		start_playing_fade_tween.parallel().tween_property(self, "pitch_scale", manager_pitch_scale, time).set_ease(Tween.EASE_OUT)
	else:
		start_playing_fade_tween.parallel().tween_property(self, "pitch_scale", pitch_target_override, time).set_ease(Tween.EASE_OUT)



func tween_manager_pitch_scale(time : float, new_manager_pitch_scale: float):
	if debug: print("AudioManager.start_playing_fade : Starting audio (with fade)")
	if tween_manager_pitch_scale_tween:
		tween_manager_pitch_scale_tween.kill()
	tween_manager_pitch_scale_tween = get_tree().create_tween().bind_node(self)
	
	tween_manager_pitch_scale_tween.parallel().tween_property(self, "manager_pitch_scale", new_manager_pitch_scale, time).set_ease(Tween.EASE_OUT_IN)
	#tween_manager_pitch_scale_tween.parallel().tween_property(self, "pitch_scale", 1.0, time).set_ease(Tween.EASE_OUT)
	#tween_manager_pitch_scale_tween.chain().tween_callback(stop_playing.bind(death_bgm_player))


func bgm_apply_effect(_effect):
	if _effect == "empty":
		#apply_sfx(empty_audio_effect)
		remove_sfx()
	#TODO : Add a match function to apply_sfx()


#   TODO how does #region work?

#region testing
func test_audio_stop_with_reverb():
	apply_sfx(upgrading_audio_effect)


func _on_timer_timeout() -> void:
	pass
