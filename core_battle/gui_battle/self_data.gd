extends MarginContainer

@onready var label_name = $InMarginContainer/VBoxContainer/Name
@onready var life_points_value = $InMarginContainer/VBoxContainer/LifePanel/LifeContainer/LifePointsValue

@onready var score_panel = $InMarginContainer/VBoxContainer/Score
@onready var text_score_value = $"InMarginContainer/VBoxContainer/Score/Score Container/Score"
@onready var text_type_name = $"InMarginContainer/VBoxContainer/Score/Score Container/Type"
@onready var text_type_symbol = $"InMarginContainer/VBoxContainer/Score/Score Container/Symbol"

@onready var entropy_panel = $InMarginContainer/VBoxContainer/Entropy
@onready var chaos_container = $InMarginContainer/VBoxContainer/Entropy/VBoxContainer/ChaosContainer



const CHAOS_AR = preload("res://assets/icons/chaos/aries-svgrepo-com.svg")
const CHAOS_BI = preload("res://assets/icons/chaos/biohazard-svgrepo-com.svg")
const CHAOS_BL = preload("res://assets/icons/chaos/blast-svgrepo-com.svg")
const CHAOS_B2 = preload("res://assets/icons/chaos/bleeding-eye-svgrepo-com.svg")
const CHAOS_BO = preload("res://assets/icons/chaos/bone-bite-svgrepo-com.svg")
const CHAOS_FO = preload("res://assets/icons/chaos/footprint-svgrepo-com.svg")
const CHAOS_SN = preload("res://assets/icons/chaos/snake-svgrepo-com.svg")
const CHAOS_SP = preload("res://assets/icons/chaos/spiked-tentacle-svgrepo-com.svg")
const CHAOS_SU = preload("res://assets/icons/chaos/suckered-tentacle-svgrepo-com.svg")
const CHAOS_FI = preload("res://assets/icons/chaos/alien-fire-svgrepo-com.svg")

const ATTACK_ICON = preload("res://assets/icons/crosshair-simple-svgrepo-com.svg")
const EVADE_ICON = preload("res://assets/icons/dialpad-circle-svgrepo-com.svg")
const DEFENSE_ICON = preload("res://assets/icons/shield-alt-svgrepo-com.svg")

var chaos_icons : Array[Texture2D] = [
	CHAOS_AR,
	CHAOS_BI,
	CHAOS_BL,
	CHAOS_B2,
	CHAOS_BO,
	CHAOS_FO,
	CHAOS_SN,
	CHAOS_SP,
	CHAOS_SU,
	CHAOS_FI]

var player_data : Array[int] = [24, 0, 0]

var attack_symbols : Array[Node]
var evade_symbols : Array[Node]

var player_name : String

var screen_side : bool = false

var score : int

var chaos_counter : int
var chaos_max : int

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
	chaos_counter = 0
	chaos_max = 3
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

func add_chaos():
	entropy_panel.set_visible(true)
	var c_container = TextureRect.new()
	c_container.set_texture(chaos_icons.pick_random())
	c_container.set_custom_minimum_size(Vector2(40,40))
	c_container.set_expand_mode(TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL)
	
	chaos_container.add_child(c_container)
	chaos_counter =chaos_counter +1

func remove_chaos_n(value : int ):
	for n in range(value):
		remove_chaos_one()

func remove_chaos_one():
	var chaos_child:Array[Node] = chaos_container.get_children()
	if !chaos_child.is_empty():
		chaos_counter =  max(chaos_counter-1,0)
		chaos_child.back().free()
	if chaos_counter == 0:
		entropy_panel.set_visible(false)

func get_chaos()-> int :
	return chaos_counter

func get_max_chaos()-> int :
	return chaos_max

func get_aberration()-> bool :
	return true if (chaos_max <= chaos_counter) else false
	#if chaos_max <= chaos_counter:
	#	return true
	#return false
