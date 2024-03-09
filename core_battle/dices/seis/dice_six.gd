extends RigidBody3D
@onready var rays = $Rays as Node3D
@onready var dice_audio = $DiceAudio as AudioStreamPlayer3D
@onready var dice_mesh = $DiceMesh
@export var mode : bool = true

const REDRIVER = preload("res://core_battle/dices/seis/attack_number.tres")
const GREENLIGHT = preload("res://core_battle/dices/seis/evade_number.tres")
const dice_max : int = 6

var dice_inital_pos : Vector3
var rays_array : Array[Node]
var current_val : int
var self_button : Button

func _ready():
	set_mode(mode)
	dice_inital_pos = get_global_position()
	rays_array = rays.get_children()
	sleeping_state_changed.connect(has_been_rolled)

	body_entered.connect(collided_effect)

func set_dice_material(a_material : Material ):
	dice_mesh.set_surface_override_material(0,a_material)

func set_mode(a_mode : bool ):
	mode = a_mode
	if mode:
		dice_mesh.set_surface_override_material(1,REDRIVER)
	else:
		dice_mesh.set_surface_override_material(1,GREENLIGHT)

func get_dice_val() -> String:
	for ray in rays_array:
		if ray.is_colliding():
			current_val = ray.name.to_int()
			return ray.name
	return "1"

func has_been_rolled():
	get_dice_val()
	#print(name," has a :" , current_val)

func collided_effect(_a_body : Node):
	dice_audio.play()
