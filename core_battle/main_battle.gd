extends Node3D

@onready var player = $Player as Node
@onready var roll_button = $MainGui/PlayerData/InMarginContainer/VBoxContainer/RollButton
@onready var dice_buttons_container = $PlayerPlay/DiceContainer

@onready var timer = $Timer

var initial_pos : Vector3
var dice_array : Array[Node]
var dice_actions : Dictionary
var battle_phase : int

enum phase_step {
	PHASE_FIRST,
	PHASE_SECOND,
	PHASE_THIRD,
	PHASE_FOURTH
	};

func _ready():
	battle_phase = phase_step.PHASE_FIRST
	dice_array = player.get_children()
	roll_button.pressed.connect(roll_all)
	timer.timeout.connect(_on_timer_timeout)

	for dice in dice_array:
		dice.self_button = Button.new()
		dice.self_button.pressed.connect(roll_one_from_selected.bind(dice)) # Not in physics process
		dice.self_button.text = dice.name
		dice_buttons_container.add_child(dice.self_button)


func _physics_process(_delta):
	
	if Input.is_action_just_pressed("b_launch"):
		roll_all()


#func batle_phases():
	#battle_phase = phase_step.PHASE_FIRST
	#timer.set_wait_time(5.0)
	#timer.set_one_shot(true)

func _on_timer_timeout():
	match battle_phase:
		phase_step.PHASE_FIRST:
			prints(self,"PHASE_FIRST")
		phase_step.PHASE_SECOND:
			if dice_rested():
				prints(self,"PHASE_SECOND")
				set_button_dice_values()
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
	timer.set_wait_time(2.0)
	timer.set_one_shot(true)
	timer.start()

func dice_rested()->bool:
	for dice in dice_array:
		prints(dice,dice.name,dice.is_sleeping())
		if !dice.is_sleeping():
			return false
	return true

func set_button_dice_values():
		for dice in dice_array:
			var text_val : String= dice.get_dice_val()
			var text_mode : String = ("a") if (dice.mode) else ("e")
			dice.self_button.text = dice.name + "\n" + text_mode + ": " + text_val
			prints ("to int",text_val.to_int())

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
