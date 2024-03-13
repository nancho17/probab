extends RigidBody3D

@onready var token_audio = $TokenAudio
@onready var heart_mesh = $Heart_Mesh

func _ready():
	body_entered.connect(collided_effect)

func collided_effect(_a_body : Node):
	token_audio.play()

func set_token_material(a_material : Material ):
	heart_mesh.set_surface_override_material(0,a_material)
