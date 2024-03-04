extends RigidBody3D
@onready var rays = $Rays as Node3D

var dice_inital_pos : Vector3
var rays_array : Array[Node]
var current_val : int

# Called when the node enters the scene tree for the first time.
func _ready():
	dice_inital_pos = get_global_position()
	rays_array = rays.get_children()
	sleeping_state_changed.connect(has_been_rolled)

func get_dice_val() -> String:
	for ray in rays_array:
		if ray.is_colliding():
			current_val = ray.name.to_int()
			return ray.name
	return "1"

func has_been_rolled():
	get_dice_val()
	print(name," has a :" , current_val)
