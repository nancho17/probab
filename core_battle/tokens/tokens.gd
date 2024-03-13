extends Node3D

const HEARTS = preload("res://core_battle/tokens/hearts.tscn")

var tokens_mat : Material

func set_tokens_material(a_material : Material ):
	tokens_mat = a_material

func add_life_token():
	var  heart_token_instance = HEARTS.instantiate()
	var pos = Vector3(randf_range(-1,1),1,randf_range(-1,1))
	heart_token_instance.set_position(pos)
	add_child( heart_token_instance )
	heart_token_instance.set_token_material(tokens_mat)

func remove_life_token_n( val : int):
	val = abs(val)
	for index in range(val):
		remove_life_token()
		
func remove_life_token():
	var array_token = get_children()
	if !array_token.is_empty():
		array_token.back().free()
