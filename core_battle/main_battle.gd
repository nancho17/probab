extends Node3D

@onready var sound_alert = $SoundEff as AudioStreamPlayer3D

@onready var roll_button = $MainGui/VBoxContainer/MarginContainer/RollButton
@onready var dice_attack_container = $PlayerPlay/VBoxContainer/DiceContainer
@onready var dice_evade_container = $PlayerPlay/VBoxContainer/DiceContainer2

@onready var timer = $Timer
@onready var result_stage = $ResultStage
@onready var acept_stage = $ResultStage/InMarginContainer/VBoxContainer/AceptStage
@onready var end_game_opt = $EndGameOpt

@onready var player = $Player as Node
@onready var enemy = $Enemy as Node

@onready var player_data = $MainGui/VBoxContainer/PlayerData
@onready var enemy_data = $MainGui/EnemyData

@onready var entropy_bar = $MainGui/Entropy/VBoxContainer/MarginContainer/ProgressBar  as TextureProgressBar

const ATTACK_ICON = preload("res://assets/icons/crosshair-simple-svgrepo-com.svg")
const EVADE_ICON = preload("res://assets/icons/dialpad-circle-svgrepo-com.svg")
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

	player_stage_val[stage_val.LIFE] = 24
	enemy_stage_val[stage_val.LIFE] = 24

	enemy_data.label_set_name("Enemy Lv 1")
	enemy_dice_array = enemy.get_children()
	for e_dice in enemy_dice_array:
		e_dice.set_dice_material(ROCK)
		if e_dice.mode:
			enemy_data.gui_add_attack_dice()
			#dice_attack_container.add_child(e_dice.self_button)
		else:
			enemy_data.gui_add_evade_dice()
			#dice_evade_container.add_child(e_dice.self_button)

	dice_array = player.get_children()
	for dice in dice_array:
		dice.self_button = Button.new()
		dice.self_button.pressed.connect(roll_one_from_selected.bind(dice)) # Not in physics process
		dice.self_button.text = dice.name
		dice.self_button.set_focus_mode(Control.FocusMode.FOCUS_NONE)
		dice.self_button.set_disabled(true)
		
		if dice.mode:
			player_data.gui_add_attack_dice()
			dice_attack_container.add_child(dice.self_button)
		else:
			player_data.gui_add_evade_dice()
			dice_evade_container.add_child(dice.self_button)
	
	set_button_dice_values()
	acept_destiny()

func _physics_process(_delta):
	if Input.is_action_just_pressed("b_launch"):
		roll_all()

func acept_destiny():
	for dice in dice_array:
		dice.self_button.set_disabled(true)

	var delta = min(player_stage_val[stage_val.EVADE] - enemy_stage_val[stage_val.ATTACK],0) 
	player_stage_val[stage_val.LIFE] += delta

	delta = min(enemy_stage_val[stage_val.EVADE] - player_stage_val[stage_val.ATTACK],0) 
	enemy_stage_val[stage_val.LIFE]+= delta
	
	player_data.set_life_points_value_int(player_stage_val[stage_val.LIFE])
	enemy_data.set_life_points_value_int(enemy_stage_val[stage_val.LIFE])


	result_stage.set_visible(false)
	sound_alert.play()

	if player_stage_val[stage_val.LIFE] <= 0:
		end_game_opt.lost_option()
		battle_phase = phase_step.PHASE_THIRD
		print("Enemy Victory")
		return

	if enemy_stage_val[stage_val.LIFE] <= 0:
		end_game_opt.victory_option()
		battle_phase = phase_step.PHASE_THIRD
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
		dice.self_button.set_disabled(false)
		if dice.mode:
			player_stage_val[stage_val.ATTACK] += dice.get_dice_val().to_int()
		else:
			player_stage_val[stage_val.EVADE] += dice.get_dice_val().to_int()

		var text_val : String= dice.get_dice_val()
		#var text_mode : String = ("a") if (dice.mode) else ("e")
		dice.self_button.text = dice.name + ": " + text_val


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
