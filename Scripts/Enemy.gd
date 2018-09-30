extends RigidBody2D

var Shuriken = preload("res://Components/Shuriken.tscn")
var alive    = true
export var flipped = false

onready var anim = $AnimationPlayer
onready var sprite = $Sprite

func _ready():
	if flipped:
		$Sprite.flip_h = false
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func die():
	alive = false
	anim.play("Die")
	$Blood.restart()
	$Blood.emitting = true
	$Timer.start()
	$ShootTimer.stop()
	
func reincarnate():
	anim.play("Idle")
	alive = true
	$ShootTimer.start()
	
func _on_Timer_timeout():
	$Blood.emitting = false

func _on_ShootTimer_timeout():
	var shuriken = Shuriken.instance()
	shuriken.parent_ninja = self
	if sprite.flip_h:
		shuriken.direction = -1
	get_node("/root/Game").add_child(shuriken)
	$Sfx/Throw.play()
	shuriken.position = position + Vector2(30 * shuriken.direction, -15)