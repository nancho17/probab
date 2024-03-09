extends MarginContainer

@onready var attack_symbols_container_1 = $InMarginContainer/VBoxContainer/DiceSymbols/HB1
@onready var attack_symbols_container_2 = $InMarginContainer/VBoxContainer/DiceSymbols/HB2

@onready var evade_symbols_container_1 = $InMarginContainer/VBoxContainer/EvadeSymbols/HB1
@onready var evade_symbols_container_2 = $InMarginContainer/VBoxContainer/EvadeSymbols/HB2

@onready var life_points_value = $InMarginContainer/VBoxContainer/HBoxContainer/LifePointsValue

@onready var label_name = $InMarginContainer/VBoxContainer/Name

@onready var attack_label = $InMarginContainer/VBoxContainer/Attack
@onready var evade_label = $InMarginContainer/VBoxContainer/Evade

const ATTACK_ICON = preload("res://assets/icons/crosshair-simple-svgrepo-com.svg")
const EVADE_ICON = preload("res://assets/icons/dialpad-circle-svgrepo-com.svg")

var attack_dices : int
var player_game_data : Array[int]

var attack_symbols : Array[Node]
var evade_symbols : Array[Node]

func _ready():
	attack_symbols = attack_symbols_container_1.get_children()
	attack_symbols.append_array(attack_symbols_container_2.get_children())
	evade_symbols = evade_symbols_container_1.get_children()
	evade_symbols.append_array(evade_symbols_container_2.get_children())

func label_set_name(name_text : String) -> void :
	label_name.set_text(name_text)

func set_life_points_value_int( value : int ) -> void :
	life_points_value.set_text(String.num_int64(value))

func set_attack_dices_number(number:int)->void:
	attack_label.set_visible(true)
	for i in range(number):
		attack_symbols[i].set_visible(true)

func set_evade_dices_number(number:int)->void:
	evade_label.set_visible(true)
	for i in range(number):
		evade_symbols[i].set_visible(true)

func gui_add_attack_dice()->void:
	attack_label.set_visible(true)
	for symbol in attack_symbols:
		if !symbol.visible:
			symbol.set_visible(true)
			break

func gui_add_evade_dice()->void:
	evade_label.set_visible(true)
	for symbol in evade_symbols:
		if !symbol.visible:
			symbol.set_visible(true)
			break
