extends MarginContainer

#Left 
@onready var left_name = $InMarginContainer/VBoxContainer/Labels/Left as Label
@onready var left_score = $InMarginContainer/VBoxContainer/Labels/LeftScore as Label
@onready var left_symbol = $InMarginContainer/VBoxContainer/Labels/LSymbol as TextureRect

@onready var right_name = $InMarginContainer/VBoxContainer/Labels/Right as Label
@onready var right_score = $InMarginContainer/VBoxContainer/Labels/RightScore as Label
@onready var right_symbol = $InMarginContainer/VBoxContainer/Labels/RSymbol as TextureRect

const ATTACK_SYMBOL = preload("res://assets/icons/crosshair-simple-svgrepo-com.svg")

func set_left_values(p_values : Array[String]):
	left_name.text = p_values[0]
	left_score.text = p_values[1]

func set_left_symbol( type : bool ):
	if type:
		left_symbol.texture = ATTACK_SYMBOL
	else:
		left_symbol.texture = ATTACK_SYMBOL

func set_right_values(p_values : Array[String]):
	right_name.text = p_values[0]
	right_name.text = p_values[1]

func set_right_symbol( type : bool ):
	if type:
		right_symbol.texture = ATTACK_SYMBOL
	else:
		right_symbol.texture = ATTACK_SYMBOL
