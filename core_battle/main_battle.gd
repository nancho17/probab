extends Node3D

@onready var player = $Player as Node

@onready var leseis = $Player/leseis_1  as RigidBody3D

var initial_pos : Vector3

var dice_array : Array[Node]

func _ready():
	dice_array = player.get_children()

func _physics_process(delta):
	if Input.is_action_just_pressed("b_launch"):
		for dice in dice_array:
			roll_da_dice(dice)

	if Input.is_action_just_pressed("k_reset"):
		var effe : String= leseis.get_dice_val()
		prints ("to int",effe.to_int())

func roll_da_dice(a_dice : RigidBody3D):
	const max_vel_angular = 10
	const max_vel_linear = 5

	var rand_ang := Vector3(randf_range(0,max_vel_angular),randf_range(0,max_vel_angular),randf_range(0,max_vel_angular))
	var rand_vel := Vector3(randf_range(max_vel_linear*0.2,max_vel_linear),randf_range(0,max_vel_linear*0.2),randf_range(0,max_vel_linear*0.2))
	#a_dice.set_freeze_enabled(true)
	a_dice.global_position = a_dice.dice_inital_pos
	#a_dice.set_freeze_enabled(false)
	a_dice.set_angular_velocity(rand_ang)
	a_dice.set_linear_velocity(rand_vel)
