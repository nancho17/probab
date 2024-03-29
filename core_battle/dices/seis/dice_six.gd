extends RigidBody3D
@onready var rays = $Rays as Node3D
@onready var dice_audio = $DiceAudio as AudioStreamPlayer3D
@onready var dice_mesh = $DiceMesh
@onready var dice_collision = $DiceCollision
@export var mode : bool = true

@export var dice_material : Material
@export var dice_numbers_material : Material

const dice_max : int = 6

var dice_inital_pos : Vector3
var rays_array : Array[Node]
var current_val : int
var self_button : Button
var	dice_disable_flag : bool

func _ready():

	if dice_material != null:
		set_dice_material(dice_material)

	if dice_numbers_material != null:
		dice_mesh.set_surface_override_material(1,dice_numbers_material)

	dice_inital_pos = get_global_position()
	rays_array = rays.get_children()
	sleeping_state_changed.connect(has_been_rolled)
	body_entered.connect(collided_effect)
	dice_enable()
	
func set_dice_material(a_material : Material ):
	dice_mesh.set_surface_override_material(0,a_material)

func set_dice_number_material(a_material : Material ):
	dice_mesh.set_surface_override_material(1,a_material)

func get_dice_val() -> String:
	for ray in rays_array:
		if ray.is_colliding():
			current_val = ray.name.to_int()
			return ray.name
	return "1"

func has_been_rolled():
	get_dice_val()

func collided_effect(_a_body : Node):
	dice_audio.play()

func dice_disable():
	dice_disable_flag = true
	set_visible(false)
	set_freeze_enabled(true)
	set_sleeping(true)
	dice_collision.set_disabled(true)

func dice_enable():
	dice_disable_flag = false
	set_visible(true)
	set_freeze_enabled(false)
	dice_collision.set_disabled(false)

func is_dice_disabled():
	return dice_disable_flag
