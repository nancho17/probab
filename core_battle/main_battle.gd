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
@onready var enemy = $Enemy/Dices
@onready var chaos = $Chaos

@onready var player_data = $MainGui/PlayerData
@onready var enemy_data = $MainGui/EnemyData

@onready var player_tokens = $Player/Tokens
@onready var enemy_tokens = $Enemy/Tokens

@onready var left_text_name = $ResultStage/InMarginContainer/VBoxContainer/Labels/Left
@onready var left_text_score = $ResultStage/InMarginContainer/VBoxContainer/Labels/LeftScore
@onready var left_score_symbol = $ResultStage/InMarginContainer/VBoxContainer/Labels/LSymbol

@onready var right_text_name = $ResultStage/InMarginContainer/VBoxContainer/Labels/Right
@onready var right_text_score = $ResultStage/InMarginContainer/VBoxContainer/Labels/RightScore
@onready var right_score_symbol = $ResultStage/InMarginContainer/VBoxContainer/Labels/RSymbol

const PLAYER_COLOR = preload("res://core_battle/dices/seis/redriver_mat.tres")
const ENEMY_COLOR = preload("res://core_battle/dices/seis/grinlight_mat.tres")

const ATTACK_ICON = preload("res://assets/icons/crosshair-simple-svgrepo-com.svg")
const EVADE_ICON = preload("res://assets/icons/dialpad-circle-svgrepo-com.svg")
const DEFENSE_ICON = preload("res://assets/icons/shield-alt-svgrepo-com.svg")

const ROCK = preload("res://assets/test_materials/rock.tres")

var enemy_dice_array : Array[Node]
var dice_array : Array[Node]
var chaos_dice_array : Array[Node]

var dice_actions : Dictionary
var battle_phase : int

enum score_type {
	SCORE_DEFENSE,
	SCORE_ATTACK,
	};

enum phase_step {
	PHASE_DEFENSE,
	PHASE_DEFENSE_CHAOS,
	#PHASE_SECOND,
	PHASE_ATTACK,
	PHASE_ATTACK_CHAOS
	};

var defender_p : Node
var attacker_p : Node

var defender_array : Array[Node]
var attacker_array : Array[Node]

var defender_token : Node
var attacker_token : Node

var physic_array_dice : Array[RigidBody3D]

func _ready():
	#get_viewport().msaa_3d = Viewport.MSAA_DISABLED
	#get_viewport().use_taa = false
	#get_viewport().use_debanding = false
	#get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
	#get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
	
	#get_viewport().debug_draw = Viewport.DEBUG_DRAW_OVERDRAW
	#get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	 

	roll_button.pressed.connect(roll_phase)
	timer.timeout.connect(_on_timer_timeout)
	acept_stage.pressed.connect(acept_destiny)

	chaos_dice_array = chaos.get_children()

	player_data.set_life_points_value_int(20)
	enemy_data.set_life_points_value_int(20)


	player_data.label_set_name("Nancho!")
	enemy_data.label_set_name("Enemy Lv 1")

	player_data.set_side(false)
	enemy_data.set_side(true)
	
	enemy_dice_array = enemy.get_children()
	for e_dice in enemy_dice_array:
		e_dice.set_dice_material(ROCK)
		e_dice.set_dice_number_material(ENEMY_COLOR)
		
	dice_array = player.get_children()
	for dice in dice_array:
		dice.set_dice_number_material(PLAYER_COLOR)
	
	player_tokens.set_tokens_material(PLAYER_COLOR)
	for number in range(20):
		player_tokens.add_life_token()

	enemy_tokens.set_tokens_material(ENEMY_COLOR)
	for number in range(20):
		enemy_tokens.add_life_token()

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

	var swapper_tokens = defender_token
	defender_token = attacker_token
	attacker_token = swapper_tokens

func set_roles_phase():
	defender_p = player_data
	attacker_p = enemy_data
	defender_array = dice_array
	attacker_array = enemy_dice_array
	defender_token = player_tokens
	attacker_token = enemy_tokens

func set_defense_phase():
	battle_phase = phase_step.PHASE_DEFENSE
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
	battle_phase = phase_step.PHASE_ATTACK
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
	battle_phase = phase_step.PHASE_DEFENSE
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
	defender_token.remove_life_token_n(delta_life)
	
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

	sound_alert.play()

	if player_data.get_life_points_value_int() <= 0:
		end_game_opt.lost_option()
		return

	if enemy_data.get_life_points_value_int() <= 0:
		end_game_opt.victory_option()
		return

	result_stage.set_visible(true)
	battle_phase = phase_step.PHASE_DEFENSE
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
		phase_step.PHASE_DEFENSE:
			prints(self,"timeout","PHASE_DEFENSE")
			rested_dice()
		phase_step.PHASE_DEFENSE_CHAOS:
			if dice_rested():
				#resolve_effects() should resolve dice effects
				resolve_aberration_dice()
			else:
				timer.set_wait_time(2.0)
				timer.set_one_shot(true)
				timer.start()	

		phase_step.PHASE_ATTACK:
			prints(self,"timeout","PHASE_ATTACK")
			rested_dice()
		phase_step.PHASE_ATTACK_CHAOS:
			if dice_rested():
				#resolve_effects() should resolve dice effects
				resolve_aberration_dice()
			else:
				timer.set_wait_time(2.0)
				timer.set_one_shot(true)
				timer.start()	
		_:
			prints(self,"timeout","PHASE TOTAL FAIL")

func roll_phase():
	match battle_phase:
		phase_step.PHASE_DEFENSE:
			prints(self,"roll_phase","PHASE_DEFENSE")
			lebutton.set_visible(false)
			for dice in defender_array:
				roll_da_dice(dice)
		phase_step.PHASE_ATTACK:
			prints(self,"roll_phase","PHASE_ATTACK")
			lebutton.set_visible(false)
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

	for dice in chaos_dice_array:
		if !dice.is_sleeping():
			return false
	return true

func player_dice_sum(player_sum : Node,player_sum_array : Array[Node]) ->int:
	var score : int = 0
	for dice in player_sum_array:
		if dice.is_dice_disabled():
			prints ( "CONTINUADISIMO")
			continue
		prints ( dice.name,": ",dice.get_dice_val().to_int())
		if dice.get_dice_val().to_int() != 1:
			score += dice.get_dice_val().to_int()
		else:
			player_sum.add_chaos()
			dice.dice_disable()
	return score

func defense_result_calc_stage():
	var score : int = player_dice_sum(defender_p,defender_array)
	defender_p.set_score(score)
	defender_p.set_score_type(score_type.SCORE_DEFENSE)
	prints("score setted PA", score)

	if defender_p.get_aberration():
		defender_p.remove_chaos_n(3)
		battle_phase = phase_step.PHASE_DEFENSE_CHAOS
		prints("LAUNCH ABERRATION!")

	match battle_phase:
		phase_step.PHASE_DEFENSE:
			set_attack_phase()
		phase_step.PHASE_DEFENSE_CHAOS:
			chaos_roll_phase()

func attack_result_calc_stage():
	var score : int = player_dice_sum(defender_p,defender_array)
	defender_p.set_score(score)
	
	score = player_dice_sum(attacker_p,attacker_array)
	attacker_p.set_score(score)
	attacker_p.set_score_type(score_type.SCORE_ATTACK)

	if attacker_p.get_aberration():
		attacker_p.remove_chaos_n(3)
		battle_phase = phase_step.PHASE_ATTACK_CHAOS
		prints("LAUNCH ABERRATION!")

	match battle_phase:
		phase_step.PHASE_ATTACK:
			conclude_stage()
		phase_step.PHASE_ATTACK_CHAOS:
			chaos_roll_phase()

func result_calc_stage():
	match battle_phase:
		phase_step.PHASE_DEFENSE:
			defense_result_calc_stage()
		phase_step.PHASE_ATTACK:
			attack_result_calc_stage()
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
	
func chaos_roll_phase():
	roll_da_dice(chaos_dice_array[0])
	timer.set_wait_time(2.0)
	timer.set_one_shot(true)
	timer.start()
	print("roll chaos")

func resolve_aberration_dice():
	var afected_p : Node
	var afected_array : Array[Node]
	var next_phase : Callable

	match battle_phase:
		phase_step.PHASE_DEFENSE_CHAOS:
			print("Aberration result: ", chaos_dice_array[0])
			afected_p = defender_p
			afected_array = defender_array
			next_phase = Callable(self, "set_attack_phase")

		phase_step.PHASE_ATTACK_CHAOS:
			print("Aberration result: ", chaos_dice_array[0])
			afected_p = attacker_p
			afected_array = attacker_array
			next_phase = Callable(self, "conclude_stage")
		_:
			return

	for dice in afected_array:
		if dice.is_dice_disabled():
			continue
		if dice.get_dice_val().to_int() <= chaos_dice_array[0].get_dice_val().to_int():
			dice.dice_disable()

	chaos_dice_array[0].dice_disable()

	var score : int = player_dice_sum(afected_p,afected_array)
	afected_p.set_score(score)
	
	next_phase.call()
