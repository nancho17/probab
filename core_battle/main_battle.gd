extends Node3D

@onready var sound_alert = $SoundEff as AudioStreamPlayer3D

##PHASE BUTTON Make single scene?

@onready var roll_button = $MainGui/Lebutton/HB2/MarginContainer/VBoxContainer/RollButton
@onready var lebutton = $MainGui/Lebutton

#Roll Panel
@onready var title_type_roll = $MainGui/Lebutton/HB2/MarginContainer/VBoxContainer/TypeRoll
@onready var who_type_roll = $MainGui/Lebutton/HB2/MarginContainer/VBoxContainer/HB1/Who
@onready var does_type_roll = $MainGui/Lebutton/HB2/MarginContainer/VBoxContainer/HB1/Does
@onready var roll_left = $MainGui/Lebutton/HB2/Left
@onready var roll_right = $MainGui/Lebutton/HB2/Right

#Result Panel
@onready var result_stage = $ResultStage
@onready var acept_stage = $ResultStage/InMarginContainer/VBoxContainer/AceptStage
@onready var negative_val = $ResultStage/InMarginContainer/VBoxContainer/Calulated/NegativeVal

@onready var end_game_opt = $EndGameOpt

@onready var timer = $Timer
@onready var player = $Player/Dices as Node
@onready var enemy = $Enemy as Node

@onready var player_data = $MainGui/PlayerData
@onready var enemy_data = $MainGui/EnemyData

@onready var entropy_bar = $MainGui/Entropy/VBoxContainer/MarginContainer/ProgressBar  as TextureProgressBar

@onready var left_text_name = $ResultStage/InMarginContainer/VBoxContainer/Labels/Left
@onready var left_text_score = $ResultStage/InMarginContainer/VBoxContainer/Labels/LeftScore
@onready var left_score_symbol = $ResultStage/InMarginContainer/VBoxContainer/Labels/LSymbol

@onready var right_text_name = $ResultStage/InMarginContainer/VBoxContainer/Labels/Right
@onready var right_text_score = $ResultStage/InMarginContainer/VBoxContainer/Labels/RightScore
@onready var right_score_symbol = $ResultStage/InMarginContainer/VBoxContainer/Labels/RSymbol


const ATTACK_ICON = preload("res://assets/icons/crosshair-simple-svgrepo-com.svg")
const EVADE_ICON = preload("res://assets/icons/dialpad-circle-svgrepo-com.svg")
const DEFENSE_ICON = preload("res://assets/icons/shield-alt-svgrepo-com.svg")

const ROCK = preload("res://assets/test_materials/rock.tres")

var enemy_dice_array : Array[Node]
var dice_array : Array[Node]

var dice_actions : Dictionary
var battle_phase : int

enum score_type {
	SCORE_DEFENSE,
	SCORE_ATTACK,
	};

enum phase_step {
	PHASE_FIRST,
	PHASE_SECOND,
	PHASE_THIRD,
	PHASE_FOURTH
	};

var defender_p : Node
var attacker_p : Node

var defender_array : Array[Node]
var attacker_array : Array[Node]

var physic_array_dice : Array[RigidBody3D]

func _ready():
	roll_button.pressed.connect(roll_phase)
	timer.timeout.connect(_on_timer_timeout)
	acept_stage.pressed.connect(acept_destiny)


	player_data.set_life_points_value_int(20)
	enemy_data.set_life_points_value_int(20)

	player_data.label_set_name("Nancho!")
	enemy_data.label_set_name("Enemy Lv 1")

	player_data.set_side(false)
	enemy_data.set_side(true)

	enemy_dice_array = enemy.get_children()
	for e_dice in enemy_dice_array:
		e_dice.set_dice_material(ROCK)

	dice_array = player.get_children()

	lebutton.visible = true
	
	
	set_roles_phase()
	set_defense_phase()


func _physics_process(_delta):
	if  !physic_array_dice.is_empty():
		for i in range(physic_array_dice.size()):
			roll_da_dice_physic(physic_array_dice.pop_back())

	if Input.is_action_just_pressed("b_launch"):
		roll_all()

func swap_roles():
	var swapper = defender_p
	defender_p = attacker_p
	attacker_p = swapper
	
	var swapper_array = defender_array
	defender_array = attacker_array
	attacker_array = swapper_array

func set_roles_phase():
	defender_p = player_data
	attacker_p = enemy_data
	defender_array = dice_array
	attacker_array = enemy_dice_array

func set_defense_phase():
	battle_phase = phase_step.PHASE_FIRST
	title_type_roll.text = "DEFENSE!"
	who_type_roll.text = defender_p.get_player_name()
	does_type_roll.text = " defends"

	roll_right.set_texture(DEFENSE_ICON)
	roll_left.set_texture(DEFENSE_ICON)

	roll_right.set_visible(defender_p.get_side())
	roll_left.set_visible(!defender_p.get_side())
	
	for dice in enemy_dice_array:
		dice.dice_disable()
	for dice in dice_array:
		dice.dice_disable()

	lebutton.set_visible(true)

func set_attack_phase():
	battle_phase = phase_step.PHASE_THIRD
	title_type_roll.text = "ATTACK!"
	who_type_roll.text = attacker_p.get_player_name()
	does_type_roll.text = " attacks"

	roll_right.set_texture(ATTACK_ICON)
	roll_left.set_texture(ATTACK_ICON)

	roll_right.set_visible(attacker_p.get_side())
	roll_left.set_visible(!attacker_p.get_side())

	lebutton.set_visible(true)

func acept_destiny():
	print("Restart Stage")
	battle_phase = phase_step.PHASE_FIRST
	result_stage.set_visible(false)
	defender_p.hide_score()
	attacker_p.hide_score()
	swap_roles()
	set_defense_phase()

func conclude_stage():
	var delta_life = min(defender_p.get_score() - attacker_p.get_score(),0)
	var defender_updated_life = defender_p.get_life_points_value_int() + delta_life
	defender_p.set_life_points_value_int(defender_updated_life)
	negative_val.text = String.num_int64(delta_life)

	var left_p : Node
	var right_p : Node

	if defender_p.get_side():
		right_p = defender_p
		left_p = attacker_p
	else:
		right_p = attacker_p
		left_p = defender_p

	left_text_name.text = left_p.get_player_name()
	left_text_score.text = left_p.get_score_text()
	left_score_symbol.texture = left_p.get_score_symbol()

	right_text_name.text = right_p.get_player_name()
	right_text_score.text = right_p.get_score_text()
	right_score_symbol.texture = right_p.get_score_symbol()

	result_stage.set_visible(true)
	sound_alert.play()

	if defender_updated_life <= 0:
		end_game_opt.lost_option()
		#end_game_opt.victory_option()
		battle_phase = phase_step.PHASE_THIRD
		print("Attacker Victory")
		return

	battle_phase = phase_step.PHASE_FIRST
	#lebutton.set_visible(true)


func rested_dice():
	if dice_rested():
		prints("dice_rested")
		result_calc_stage()
	else:
		print("Not yet capo")
		timer.set_wait_time(2.0)
		timer.set_one_shot(true)
		timer.start()


func _on_timer_timeout():
	match battle_phase:
		phase_step.PHASE_FIRST:
			prints(self,"timeout","PHASE_FIRST")
		phase_step.PHASE_SECOND:
			rested_dice()
		phase_step.PHASE_THIRD:
			prints(self,"timeout","PHASE_THIRD")
		phase_step.PHASE_FOURTH:
			rested_dice()
		_:
			prints(self,"timeout","PHASE TOTAL FAIL")

func roll_phase():
	match battle_phase:
		phase_step.PHASE_FIRST:
			prints(self,"roll_phase","PHASE_FIRST")
			lebutton.set_visible(false)
			battle_phase = phase_step.PHASE_SECOND
			for dice in defender_array:
				roll_da_dice(dice)
		phase_step.PHASE_THIRD:
			prints(self,"roll_phase","PHASE_THIRD")
			lebutton.set_visible(false)
			battle_phase = phase_step.PHASE_FOURTH
			for dice in attacker_array:
				roll_da_dice(dice)
		_:
			return

	timer.set_wait_time(2.0)
	timer.set_one_shot(true)
	timer.start()


func roll_all():

	for dice in dice_array:
		dice.visible = true
		roll_da_dice(dice)

	for dice in enemy_dice_array:
		roll_da_dice(dice)


func dice_rested()->bool:
	for dice in enemy_dice_array:
		if !dice.is_sleeping():
			return false

	for dice in dice_array:
		if !dice.is_sleeping():
			return false

	return true


func result_calc_stage():
	var score : int = 0
	for dice in defender_array:
		prints ( dice.name,": ",dice.get_dice_val().to_int())
		score += dice.get_dice_val().to_int()

	defender_p.set_score(score)
	defender_p.set_score_type(score_type.SCORE_DEFENSE)
	prints("score setted PA", score)

	score = 0
	for dice in attacker_array:
		prints ( dice.name,": ",dice.get_dice_val().to_int())
		score += dice.get_dice_val().to_int()

	match battle_phase:
		phase_step.PHASE_SECOND:
			set_attack_phase()
		phase_step.PHASE_FOURTH:
			attacker_p.set_score(score)
			attacker_p.set_score_type(score_type.SCORE_ATTACK)
			conclude_stage()
		_:
			return

func roll_da_dice(a_dice : RigidBody3D):
	physic_array_dice.append(a_dice)

func roll_da_dice_physic(a_dice : RigidBody3D):
	a_dice.dice_enable()
	const max_vel_angular = 40
	const max_vel_linear = 15

	var rand_ang := Vector3(randf_range(-max_vel_angular,max_vel_angular),randf_range(-max_vel_angular,max_vel_angular),randf_range(-max_vel_angular,max_vel_angular))
	var rand_vel := Vector3(randf_range(-max_vel_linear,max_vel_linear),randf_range(0,max_vel_linear),randf_range(0,max_vel_linear))
	a_dice.set_freeze_enabled(true)
	a_dice.set_global_position(a_dice.dice_inital_pos)
	a_dice.set_freeze_enabled(false)
	a_dice.set_angular_velocity(rand_ang)
	a_dice.set_linear_velocity(rand_vel)
