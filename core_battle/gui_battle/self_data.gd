extends MarginContainer

@onready var label_name = $InMarginContainer/VBoxContainer/Name
@onready var life_points_value = $InMarginContainer/VBoxContainer/LifePanel/LifeContainer/LifePointsValue

@onready var score_panel = $InMarginContainer/VBoxContainer/Score
@onready var text_score_value = $"InMarginContainer/VBoxContainer/Score/Score Container/Score"
@onready var text_type_name = $"InMarginContainer/VBoxContainer/Score/Score Container/Type"
@onready var text_type_symbol = $"InMarginContainer/VBoxContainer/Score/Score Container/Symbol"

@onready var entropy_panel = $InMarginContainer/VBoxContainer/Entropy

const ATTACK_ICON = preload("res://assets/icons/crosshair-simple-svgrepo-com.svg")
const EVADE_ICON = preload("res://assets/icons/dialpad-circle-svgrepo-com.svg")
const DEFENSE_ICON = preload("res://assets/icons/shield-alt-svgrepo-com.svg")

var player_data : Array[int] = [24, 0, 0]

var attack_symbols : Array[Node]
var evade_symbols : Array[Node]

var player_name : String

var screen_side : bool = false

var score : int

enum score_type {
	SCORE_DEFENSE,
	SCORE_ATTACK,
	};

enum stage_val {
	LIFE,
	ATTACK,
	EVADE,
	};

var score_type_var : int


func _ready():
	score_panel.set_visible(false)
	entropy_panel.set_visible(false)

func set_score_type(type : int) -> void:
	score_type_var = type
	match score_type_var:
		score_type.SCORE_DEFENSE:
			text_type_name.text = "Defense Points"
			text_type_symbol.set_texture(DEFENSE_ICON)
		score_type.SCORE_ATTACK:
			text_type_name.text = "Attack Points"
			text_type_symbol.set_texture(ATTACK_ICON)


func hide_score() -> void:
	score_panel.set_visible(false)

func set_score(number : int) -> void:
	text_score_value.set_text(String.num_int64(number))
	score = number
	score_panel.set_visible(true)

func get_score() -> int: 
	return score

func get_score_text() -> String: 
	return text_score_value.get_text()

func get_score_symbol() -> CompressedTexture2D:
	match score_type_var:
		score_type.SCORE_DEFENSE:
			return DEFENSE_ICON
		score_type.SCORE_ATTACK:
			return ATTACK_ICON
	return EVADE_ICON

func set_side(side : bool) -> void: 
	screen_side = side

func get_side() -> bool: 
	return screen_side

func get_player_name() -> String: 
	return player_name

func label_set_name(name_text : String) -> void :
	player_name = name_text
	label_name.set_text(name_text)

func set_life_points_value_int( value : int ) -> void :
	player_data[0] = value
	life_points_value.set_text(String.num_int64(value))

func get_life_points_value_int() -> int :
	return player_data[0]


