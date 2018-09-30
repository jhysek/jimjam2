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
		monitoring = false
	sprite.rotation_degrees += delta * ROTATION_SPEED
	position.x = position.x + SPEED * delta * direction

func _on_Shuriken_body_entered(body):
	if parent_ninja == body:
		return
		
	if body.is_in_group("Enemy") and parent_ninja != body:
		queue_free()
		body.die()
		
	elif not body.is_in_group("Player"):
		stucked = true
		set_physics_process(false)
		
	elif not stucked and body != parent_ninja and body.alive:
	  body.die()
	
	elif not stucked and body != parent_ninja and not body.alive:
		stucked = true
		set_physics_process(false)
		body.shurikens.append(self)
		body.die()
