extends Control

var global
var options

func _ready():
	global = get_node("/root/Global")
	options = get_node("/root/Options")
	var options_title = global.make_title("Options")
	var video_title = global.make_subtitle("Video")
	var audio_title = global.make_subtitle("Audio")
	var input_title = global.make_subtitle("Input")
	get_node("OptionsPanel/Title").set_bbcode(options_title)
	get_node("OptionsPanel/Video/Title").set_bbcode(video_title)
	get_node("OptionsPanel/Audio/Title").set_bbcode(audio_title)
	get_node("OptionsPanel/Input/Title").set_bbcode(input_title)
	setup_shadow_type_optionbutton()

func setup_shadow_type_optionbutton():
	var shadow_type_optionbutton = get_node("OptionsPanel/Video/ShadowType/OptionButton")
	shadow_type_optionbutton.add_item(tr("ShadowsNone"))	# 0
	shadow_type_optionbutton.add_item(tr("ShadowsPCF5"))	# 1
	shadow_type_optionbutton.add_item(tr("ShadowsPCF13"))	# 2
	shadow_type_optionbutton.add_item(tr("ShadowsESM"))		# 3
	# Select the value stored in options
	shadow_type_optionbutton.select(options.get("video", "shadow_type"))

func _on_MouseSensitivity_enter_tree():
	var vs = float(options.get("input", "view_sensitivity"))
	get_node("OptionsPanel/Input/MouseSensitivity/HSlider").set_value(vs)
	get_node("OptionsPanel/Input/MouseSensitivity/LineEdit").set_text(str(vs))
	get_node("/root/Global").view_sensitivity = vs

func _on_MouseSensitivity_value_changed(value):
	global = get_node("/root/Global")
	global.view_sensitivity = float(value)
	options.set("input", "view_sensitivity", float(value))
	get_node("OptionsPanel/Input/MouseSensitivity/LineEdit").set_text(str(value))

func _on_MouseSensitivity_LineEdit_text_entered(text):
	text = float(text)
	if text <= 0.5:
		text = 0.5
	elif text >= 10:
		text = 10
	get_node("OptionsPanel/Input/MouseSensitivity/HSlider").set_value(text)
	get_node("/root/Global").view_sensitivity = text

func _on_FPSLimit_enter_tree():
	options = get_node("/root/Options")
	get_node("OptionsPanel/Video/FPSLimit/LineEdit").set_text(str(options.get("video", "fps_max")))
	OS.set_target_fps(options.get("video", "fps_max"))

func _on_FPSLimit_text_entered(text):
	# Prevent too low FPS limit
	if int(text) < 20:
		OS.set_target_fps(20)
		options.set("video", "fps_max", 20)
	else:
		OS.set_target_fps(int(text))
		options.set("video", "fps_max", int(text))

func _on_ShadowType_enter_tree():
	options = get_node("/root/Options")
	Globals.set("rasterizer/shadow_filter", options.get("video", "shadow_type"))

func _on_ShadowType_item_selected(ID):
	Globals.set("rasterizer/shadow_filter", ID)
	options.set("video", "shadow_type", ID)

func _on_SoundVolume_enter_tree():
	options = get_node("/root/Options")
	var sv = float(options.get("audio", "sound_volume"))
	get_node("OptionsPanel/Audio/SoundVolume/HSlider").set_value(sv)
	get_node("OptionsPanel/Audio/SoundVolume/LineEdit").set_text(str(sv))
	AudioServer.set_fx_global_volume_scale(float(sv))

func _on_SoundVolume_value_changed(value):
	AudioServer.set_fx_global_volume_scale(float(value))
	options.set("audio", "sound_volume", float(value))
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
	options = get_node("/root/Options")
	var mv = float(options.get("audio", "music_volume"))
	get_node("OptionsPanel/Audio/MusicVolume/HSlider").set_value(mv)
	get_node("OptionsPanel/Audio/MusicVolume/LineEdit").set_text(str(mv))
	AudioServer.set_stream_global_volume_scale(float(mv))

func _on_MusicVolume_value_changed(value):
	AudioServer.set_stream_global_volume_scale(float(value))
	options.set("audio", "music_volume", float(value))
	get_node("OptionsPanel/Audio/MusicVolume/LineEdit").set_text(str(value))

func _on_MusicVolume_LineEdit_text_entered(text):
	text = float(text)
	if text <= 0:
		text = 0
	elif text >= 2:
		text = 2
	AudioServer.set_stream_global_volume_scale(float(text))
	get_node("OptionsPanel/Audio/MusicVolume/HSlider").set_value(text)
