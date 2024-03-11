extends Node3D

@onready var sound_alert = $SoundEff as AudioStreamPlayer3D

##PHASE BUTTON Make single scene?

@onready var roll_button = $MainGui/Lebutton/HB2/MarginContainer/VBoxContainer/RollButton
@onready var lebutton = $MainGui/Lebutton


@onready var title_type_roll = $MainGui/Lebutton/HB2/MarginContainer/VBoxContainer/TypeRoll
@onready var who_type_roll = $MainGui/Lebutton/HB2/MarginContainer/VBoxContainer/HB1/Who
@onready var does_type_roll = $MainGui/Lebutton/HB2/MarginContainer/VBoxContainer/HB1/Does
@onready var roll_left = $MainGui/Lebutton/HB2/Left
@onready var roll_right = $MainGui/Lebutton/HB2/Right


@onready var dice_attack_container = $PlayerPlay/VBoxContainer/DiceContainer
@onready var dice_evade_container = $PlayerPlay/VBoxContainer/DiceContainer2

@onready var timer = $Timer
@onready var result_stage = $ResultStage
@onready var acept_stage = $ResultStage/InMarginContainer/VBoxContainer/AceptStage
@onready var end_game_opt = $EndGameOpt

@onready var player = $Player/Dices as Node
@onready var enemy = $Enemy as Node

@onready var player_data = $MainGui/PlayerData
@onready var enemy_data = $MainGui/EnemyData

@onready var entropy_bar = $MainGui/Entropy/VBoxContainer/MarginContainer/ProgressBar  as TextureProgressBar

const ATTACK_ICON = preload("res://assets/icons/crosshair-simple-svgrepo-com.svg")
const EVADE_ICON = preload("res://assets/icons/dialpad-circle-svgrepo-com.svg")
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
	
	#acept_destiny()

func _physics_process(_delta):
	if Input.is_action_just_pressed("b_launch"):
		roll_all()

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

	roll_right.set_visible(defender_p.get_side())
	roll_left.set_visible(!defender_p.get_side())

	lebutton.set_visible(true)

func set_attack_phase():
	battle_phase = phase_step.PHASE_THIRD
	title_type_roll.text = "ATTACK!"
	who_type_roll.text = attacker_p.get_player_name()
	does_type_roll.text = " attacks"

	roll_right.set_visible(attacker_p.get_side())
	roll_left.set_visible(!attacker_p.get_side())

	lebutton.set_visible(true)



func acept_destiny():
	var defender_updated_life = defender_p.get_life_points_value_int()- min(defender_p.get_score() - attacker_p.get_score(),0)
	defender_p.set_life_points_value_int(defender_updated_life)
	result_stage.set_visible(false)
	sound_alert.play()

	if defender_updated_life <= 0:
		end_game_opt.lost_option()
		#end_game_opt.victory_option()
		battle_phase = phase_step.PHASE_THIRD
		print("Attacker Victory")
		return

	battle_phase = phase_step.PHASE_FIRST
	lebutton.set_visible(true)


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
			prints(self,"PHASE_FIRST")
		phase_step.PHASE_SECOND:
			rested_dice()
		phase_step.PHASE_THIRD:
			rested_dice()
		phase_step.PHASE_FOURTH:
			prints(self,"PHASE_FOURTH")
		_:
			prints(self,"PHASE TOTAL FAIL")

func roll_phase():
	match battle_phase:
		phase_step.PHASE_FIRST:
			prints(self,"PHASE_FIRST")
			lebutton.set_visible(false)
			battle_phase = phase_step.PHASE_SECOND
			for dice in defender_array:
				roll_da_dice(dice)
		phase_step.PHASE_THIRD:
			lebutton.set_visible(false)
			battle_phase = phase_step.PHASE_SECOND
			for dice in attacker_array:
				roll_da_dice(dice)
		_:
			return

	timer.set_wait_time(2.0)
	timer.set_one_shot(true)
	timer.start()


func roll_all():
	if battle_phase != phase_step.PHASE_FIRST:
		return

	lebutton.set_visible(false)

	battle_phase = phase_step.PHASE_SECOND
	for dice in dice_array:
		roll_da_dice(dice)

	for dice in enemy_dice_array:
		roll_da_dice(dice)

	timer.set_wait_time(2.0)
	timer.set_one_shot(true)
	timer.start()

func dice_rested()->bool:
	for dice in enemy_dice_array:
		if !dice.is_sleeping():
			return false

	for dice in dice_array:
		if !dice.is_sleeping():
			return false

	return true


func result_calc_stage():
	match battle_phase:
		phase_step.PHASE_SECOND:
			var score : int = 0
			for dice in defender_array:
				prints ( dice.name,": ",dice.get_dice_val().to_int())
				score += dice.get_dice_val().to_int()
			defender_p.set_score(score)
			defender_p.set_score_type(score_type.SCORE_DEFENSE)
			prints("score setted PA", score)
			set_attack_phase()
		_:
			return

	#for dice in enemy_dice_array:
		#if dice.mode:
			#enemy_stage_val[stage_val.ATTACK] += dice.get_dice_val().to_int()
		#else:
			#enemy_stage_val[stage_val.EVADE] += dice.get_dice_val().to_int()



	for dice in dice_array:
		var text_val : String= dice.get_dice_val()
		#var text_mode : String = ("a") if (dice.mode) else ("e")



func roll_one_from_selected(dice : RigidBody3D):
	print(battle_phase)
	result_stage.set_visible(false)
	roll_da_dice(dice)
	timer.set_wait_time(2.0)
	timer.set_one_shot(true)
	timer.start()
	
	entropy_bar.value +=1
	#Add aberrati


func roll_da_dice(a_dice : RigidBody3D):
	const max_vel_angular = 40
	const max_vel_linear = 15

	var rand_ang := Vector3(randf_range(-max_vel_angular,max_vel_angular),randf_range(-max_vel_angular,max_vel_angular),randf_range(-max_vel_angular,max_vel_angular))
	var rand_vel := Vector3(randf_range(-max_vel_linear,max_vel_linear),randf_range(0,max_vel_linear),randf_range(0,max_vel_linear))
	a_dice.set_freeze_enabled(true)
	a_dice.set_global_position(a_dice.dice_inital_pos)
	a_dice.set_freeze_enabled(false)
	a_dice.set_angular_velocity(rand_ang)
	a_dice.set_linear_velocity(rand_vel)
