extends MarginContainer

@onready var title = $MarginContainer/VBoxContainer/Title
@onready var next_enemy = $"MarginContainer/VBoxContainer/Next Enemy"
@onready var main_menu = $"MarginContainer/VBoxContainer/Main Menu"

func _ready():
	main_menu.pressed.connect(back_to_menu_scene_)
	next_enemy.pressed.connect(next_enemy_scene)

func back_to_menu_scene_():
	#main_scene.request_ready()
	#get_tree().change_scene_to_packed(main_scene)
	var this_scene = get_tree().get_current_scene()
	prints("name ",this_scene.name)
	get_tree().change_scene_to_file("res://the_main.tscn")



func next_enemy_scene():
	get_tree().change_scene_to_file("res://the_main.tscn")
	## Get_next_enemy
	## Change next enemy
	##main_scene.request_ready()
	##get_tree().change_scene_to_packed(main_scene)

func victory_option():
	title.text = "Victory!"
	set_visible(true)

func lost_option():
	title.text = "Defeat"
	next_enemy.	set_visible(false)
	set_visible(true)

