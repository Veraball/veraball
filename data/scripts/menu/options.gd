extends Control

onready var shadow_type_optionbutton = get_node("OptionsPanel/Video/ShadowType/OptionButton")
onready var options_title = Game.make_title("Options")
onready var video_title = Game.make_subtitle("Video")
onready var audio_title = Game.make_subtitle("Audio")
onready var input_title = Game.make_subtitle("Input")

func _ready():
	get_node("OptionsPanel/Title").set_bbcode(options_title)
	get_node("OptionsPanel/Video/Title").set_bbcode(video_title)
	get_node("OptionsPanel/Audio/Title").set_bbcode(audio_title)
	get_node("OptionsPanel/Input/Title").set_bbcode(input_title)
	setup_shadow_type_optionbutton()

func setup_shadow_type_optionbutton():
	shadow_type_optionbutton.add_item(tr("ShadowsNone"))	# 0
	shadow_type_optionbutton.add_item(tr("ShadowsPCF5"))	# 1
	shadow_type_optionbutton.add_item(tr("ShadowsPCF13"))	# 2
	shadow_type_optionbutton.add_item(tr("ShadowsESM"))		# 3
	# Select the value stored in options
	shadow_type_optionbutton.select(Options.get_setting("video", "shadow_type"))

func _on_MouseSensitivity_enter_tree():
	var vs = float(Options.get_setting("input", "view_sensitivity"))
	get_node("OptionsPanel/Input/MouseSensitivity/HSlider").set_value(vs)
	get_node("OptionsPanel/Input/MouseSensitivity/LineEdit").set_text(str(vs))
	Game.view_sensitivity = vs

func _on_MouseSensitivity_value_changed(value):
	Game.view_sensitivity = float(value)
	Options.set_setting("input", "view_sensitivity", float(value))
	get_node("OptionsPanel/Input/MouseSensitivity/LineEdit").set_text(str(value))

func _on_MouseSensitivity_LineEdit_text_entered(text):
	text = float(text)
	if text <= 0.5:
		text = 0.5
	elif text >= 10:
		text = 10
	get_node("OptionsPanel/Input/MouseSensitivity/HSlider").set_value(text)
	Game.view_sensitivity = text

func _on_FPSLimit_enter_tree():
	get_node("OptionsPanel/Video/FPSLimit/LineEdit").set_text(str(Options.get_setting("video", "fps_max")))
	Engine.target_fps = Options.get_setting("video", "fps_max")

func _on_FPSLimit_text_entered(text):
	# Prevent too low FPS limit
	if int(text) < 20:
		OS.set_target_fps(20)
		Options.set_setting("video", "fps_max", 20)
	else:
		OS.set_target_fps(int(text))
		Options.set_setting("video", "fps_max", int(text))

func _on_ShadowType_enter_tree():
	ProjectSettings.set_setting("rasterizer/shadow_filter", Options.get_setting("video", "shadow_type"))

func _on_ShadowType_item_selected(ID):
	ProjectSettings.set_setting("rasterizer/shadow_filter", ID)
	Options.set_setting("video", "shadow_type", ID)

func _on_SoundVolume_enter_tree():
	var sv = float(Options.get_setting("audio", "sound_volume"))
	get_node("OptionsPanel/Audio/SoundVolume/HSlider").set_value(sv)
	get_node("OptionsPanel/Audio/SoundVolume/LineEdit").set_text(str(sv))
	#AudioServer.set_fx_global_volume_scale(float(sv))

func _on_SoundVolume_value_changed(value):
	#AudioServer.set_fx_global_volume_scale(float(value))
	Options.set_setting("audio", "sound_volume", float(value))
	get_node("OptionsPanel/Audio/SoundVolume/LineEdit").set_text(str(value))

func _on_SoundVolume_LineEdit_text_entered(text):
	text = float(text)
	if text <= 0:
		text = 0
	elif text >= 2:
		text = 2
	AudioServer.set_fx_global_volume_scale(float(text))
	get_node("OptionsPanel/Audio/SoundVolume/HSlider").set_value(text)

func _on_MusicVolume_enter_tree():
	var mv = float(Options.get_setting("audio", "music_volume"))
	get_node("OptionsPanel/Audio/MusicVolume/HSlider").set_value(mv)
	get_node("OptionsPanel/Audio/MusicVolume/LineEdit").set_text(str(mv))
	#AudioServer.set_stream_global_volume_scale(float(mv))

func _on_MusicVolume_value_changed(value):
	#AudioServer.set_stream_global_volume_scale(float(value))
	Options.set_setting("audio", "music_volume", float(value))
	get_node("OptionsPanel/Audio/MusicVolume/LineEdit").set_text(str(value))

func _on_MusicVolume_LineEdit_text_entered(text):
	text = float(text)
	if text <= 0:
		text = 0
	elif text >= 2:
		text = 2
	AudioServer.set_stream_global_volume_scale(float(text))
	get_node("OptionsPanel/Audio/MusicVolume/HSlider").set_value(text)

