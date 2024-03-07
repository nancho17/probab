extends Node3D

@onready var roll_button = $MainGui/PlayerData/InMarginContainer/VBoxContainer/RollButton
@onready var dice_buttons_container = $PlayerPlay/DiceContainer
@onready var timer = $Timer
@onready var result_stage = $ResultStage
@onready var acept_stage = $ResultStage/InMarginContainer/VBoxContainer/AceptStage

@onready var player_life_points = $MainGui/PlayerData/InMarginContainer/VBoxContainer/HBoxContainer/LifePointsValue
@onready var enemy_life_points = $MainGui/EnemyData/InMarginContainer/VBoxContainer/HBoxContainer/LifePointsValue
@onready var end_game_opt = $EndGameOpt

@onready var player = $Player as Node
@onready var enemy = $Enemy as Node

const ROCK = preload("res://assets/test_materials/rock.tres")

var enemy_dice_array : Array[Node]
var dice_array : Array[Node]

var dice_actions : Dictionary
var battle_phase : int

enum stage_val {
	LIFE,
	ATTACK,
	EVADE,
	};

var player_stage_val : Array[int] = [24, 0, 0]
var enemy_stage_val : Array[int] = [24, 0, 0]

enum phase_step {
	PHASE_FIRST,
	PHASE_SECOND,
	PHASE_THIRD,
	PHASE_FOURTH
	};

func _ready():
	roll_button.pressed.connect(roll_all)
	timer.timeout.connect(_on_timer_timeout)
	acept_stage.pressed.connect(acept_destiny)
	
	battle_phase = phase_step.PHASE_FIRST

	player_stage_val[stage_val.LIFE] = 44
	enemy_stage_val[stage_val.LIFE] = 44

	enemy_dice_array = enemy.get_children()
	for e_dice in enemy_dice_array:
		e_dice.set_dice_material(ROCK)

	dice_array = player.get_children()

	for dice in dice_array:
		dice.self_button = Button.new()
		dice.self_button.pressed.connect(roll_one_from_selected.bind(dice)) # Not in physics process
		dice.self_button.text = dice.name
		dice.self_button.set_focus_mode(Control.FocusMode.FOCUS_NONE) 
		dice_buttons_container.add_child(dice.self_button)

	acept_destiny()


func _physics_process(_delta):
	
	if Input.is_action_just_pressed("b_launch"):
		roll_all()


func acept_destiny():
	
	var delta = min(player_stage_val[stage_val.EVADE] - enemy_stage_val[stage_val.ATTACK],0) 
	player_stage_val[stage_val.LIFE] += delta

	delta = min(enemy_stage_val[stage_val.EVADE] - player_stage_val[stage_val.ATTACK],0) 
	enemy_stage_val[stage_val.LIFE]+= delta

	player_life_points.text = String.num_int64(player_stage_val[stage_val.LIFE])
	enemy_life_points.text = String.num_int64(enemy_stage_val[stage_val.LIFE])

	result_stage.set_visible(false)

	if player_stage_val[stage_val.LIFE] <= 0:
		end_game_opt.lost_option()
		print("Enemy Victory")
		return

	if enemy_stage_val[stage_val.LIFE] <= 0:
		end_game_opt.victory_option()
		print("Player Victory")
		return

	battle_phase= phase_step.PHASE_FIRST
	roll_button.set_disabled(false)

func _on_timer_timeout():
	match battle_phase:
		phase_step.PHASE_FIRST:
			prints(self,"PHASE_FIRST")
		phase_step.PHASE_SECOND:
			if dice_rested():
				prints(self,"PHASE_SECOND")
				result_calc_stage()
			else:
				print("Not yet capo")
				timer.set_wait_time(2.0)
				timer.set_one_shot(true)
				timer.start()
		phase_step.PHASE_THIRD:
				prints(self,"PHASE_THIRD")
		_:
			prints(self,"PHASE TOTAL FAIL")

func roll_all():
	if battle_phase != phase_step.PHASE_FIRST:
		return
	roll_button.set_disabled(true)
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
	set_button_dice_values()
	var p_future =  player_stage_val.duplicate()
	var e_future = enemy_stage_val.duplicate()
	
	var delta = min(player_stage_val[stage_val.EVADE] - enemy_stage_val[stage_val.ATTACK],0) 
	p_future[stage_val.LIFE] = player_stage_val[stage_val.LIFE] + delta

	delta = min(enemy_stage_val[stage_val.EVADE] - player_stage_val[stage_val.ATTACK],0) 
	e_future[stage_val.LIFE] = enemy_stage_val[stage_val.LIFE] + delta

	print(player_stage_val[stage_val.LIFE])
	print(p_future[stage_val.LIFE])

	result_stage.set_player_values(p_future)
	result_stage.set_enemy_values(e_future)
	result_stage.set_visible(true)

func set_button_dice_values():
	player_stage_val[stage_val.ATTACK] = 0
	enemy_stage_val[stage_val.ATTACK] = 0
	player_stage_val[stage_val.EVADE] = 0
	enemy_stage_val[stage_val.EVADE] = 0

	for dice in enemy_dice_array:
		if dice.mode:
			enemy_stage_val[stage_val.ATTACK] += dice.get_dice_val().to_int()
		else:
			enemy_stage_val[stage_val.EVADE] += dice.get_dice_val().to_int()

	for dice in dice_array:
		if dice.mode:
			player_stage_val[stage_val.ATTACK] += dice.get_dice_val().to_int()
		else:
			player_stage_val[stage_val.EVADE] += dice.get_dice_val().to_int()

		var text_val : String= dice.get_dice_val()
		var text_mode : String = ("a") if (dice.mode) else ("e")
		dice.self_button.text = dice.name + "\n" + text_mode + ": " + text_val


func roll_one_from_selected(dice : RigidBody3D):
	roll_da_dice(dice)
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
