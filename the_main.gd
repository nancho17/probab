extends Control

@onready var audio_stream_player = $AudioStreamPlayer
@onready var play_button = $Panel/MarginContainer/MenuManager/MarginContainer/VBoxContainer/PlayButton
@onready var settings_button = $Panel/MarginContainer/MenuManager/MarginContainer/VBoxContainer/SettingsButton
@onready var quit_button = $Panel/MarginContainer/MenuManager/MarginContainer/VBoxContainer/QuitButton

const battle_scene = preload("res://core_battle/main_battle.tscn")

func _ready() -> void:
	audio_stream_player.play(1.7)
	quit_button.visible = not OS.has_feature("HTML5")
	play_button.pressed.connect(_on_play_button_pressed)
	settings_button.pressed.connect(_on_setings_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	audio_stream_player.finished.connect(replay_audio)

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(battle_scene)

func _on_setings_button_pressed() -> void:
	print("main_menu.go_settings_menu()")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func replay_audio() -> void:
	audio_stream_player.play()
