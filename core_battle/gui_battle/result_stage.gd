extends MarginContainer

#player
@onready var player_life = $InMarginContainer/VBoxContainer/Life/PResult as Label
@onready var player_attack = $InMarginContainer/VBoxContainer/Attack/PResult as Label
@onready var player_evade = $InMarginContainer/VBoxContainer/Evade/PResult as Label

#enemy
@onready var enemy_life = $InMarginContainer/VBoxContainer/Life/EResult as Label
@onready var enemy_attack = $InMarginContainer/VBoxContainer/Attack/EResult as Label
@onready var enemy_evade = $InMarginContainer/VBoxContainer/Evade/EResult as Label

func set_player_values(p_values : Array[int]):
	player_life.text = String.num_int64(p_values[0])
	player_attack.text = String.num_int64(p_values[1])
	player_evade.text = String.num_int64(p_values[2])

func set_enemy_values(p_values : Array[int]):
	enemy_life.text = String.num_int64(p_values[0])
	enemy_attack.text = String.num_int64(p_values[1])
	enemy_evade.text = String.num_int64(p_values[2])
