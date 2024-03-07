extends MarginContainer

@onready var title = $MarginContainer/VBoxContainer/Title
@onready var next_enemy = $"MarginContainer/VBoxContainer/Next Enemy"
@onready var main_menu = $"MarginContainer/VBoxContainer/Main Menu"

func victory_option():
	title.text = "Le victory eeee!"
	set_visible(true)

func lost_option():
	title.text = "Game Over"
	next_enemy.	set_visible(false)
	set_visible(true)

