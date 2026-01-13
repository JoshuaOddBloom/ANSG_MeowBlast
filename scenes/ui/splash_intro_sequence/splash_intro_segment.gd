extends Control
class_name SplashIntroSeqment

signal splash_segment_finished

@onready var debug_label: Label = %DebugLabel
@onready var bg_color_rect: ColorRect = %BGColorRect
@onready var title_label: Label = %TitleLabel
@onready var branding_marker_2d: Marker2D = %BrandingMarker2D
@onready var sequence_animation_player: AnimationPlayer = %SequenceAnimationPlayer
#Logo
@onready var logo: Node2D = %Logo
@onready var logo_animation_player: AnimationPlayer = %LogoAnimationPlayer


func _ready() -> void:
	debug_label.visible = GameEvents.debug


func _process(_delta: float) -> void:
	var viewport_size = get_viewport_rect().size # THANK YOU STUDIOBOX GAMES (YT)
	if branding_marker_2d.position.x != viewport_size.x / 2:
		branding_marker_2d.position.x = viewport_size.x / 2
	if branding_marker_2d.position.y != viewport_size.y / 2:
		branding_marker_2d.position.y = viewport_size.y / 2


func start():
	print("SEQUENCE STARTED")
	if GameEvents.main_menu_shown_before or GameEvents.game_played:
		sequence_animation_player.play("quick_open")
	else:
		sequence_animation_player.play("cold_open")


func logo_play_auto_animation():
	logo_animation_player.play("auto")
	await logo_animation_player.animation_finished


func play_out_animations():
	if logo_animation_player.has_animation("out"):
		logo_animation_player.play("out")
	if sequence_animation_player.has_animation("out"):
		sequence_animation_player.play("out")
		await sequence_animation_player.animation_finished
	print("SEQUENCE FINISHED")
	self.hide()
	splash_segment_finished.emit()
	#node will be freed from the sequencer
