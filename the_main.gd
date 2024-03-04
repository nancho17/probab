extends Control




@onready var play_button = $Panel/MarginContainer/MenuManager/MarginContainer/VBoxContainer/PlayButton
@onready var quit_button = $Panel/MarginContainer/MenuManager/MarginContainer/VBoxContainer/QuitButton
@onready var settings_button = $Panel/MarginContainer/MenuManager/MarginContainer/VBoxContainer/SettingsButton

const battle_scene = preload("res://core_battle/main_battle.tscn")

func _ready() -> void:
	print("readynode")
	quit_button.visible = not OS.has_feature("HTML5")
	play_button.pressed.connect(_on_play_button_pressed)
	settings_button.pressed.connect(_on_setings_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(battle_scene)


func _on_setings_button_pressed() -> void:
	print("main_menu.go_settings_menu()")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

