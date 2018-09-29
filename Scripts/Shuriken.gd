extends Area2D

const ROTATION_SPEED = 1500
const SPEED          = 1000
export var stucked = false
onready var sprite = $Sprite;

var direction = 1
var parent_ninja

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	if stucked:
		set_physics_process(false)
	sprite.rotation_degrees += delta * ROTATION_SPEED
	position.x = position.x + SPEED * delta * direction

func _on_Shuriken_body_entered(body):
	if not body.is_in_group("Player"):
		stucked = true
		set_physics_process(false)
	elif not stucked and body != parent_ninja:
	  body.die()