extends KinematicBody2D

export var GRAVITY = 40 * 60
export var SPEED   = 30000
export var JUMP_SPEED  = -950

onready var sprite = $Sprite
onready var anim   = $AnimationPlayer
onready var ray1   = $RayLeft
onready var ray2   = $RayRight
onready var game   = get_node("/root/Game")

var Shuriken = preload("res://Components/Shuriken.tscn")

var record = []
var imitating = false
var imitating_cmd = ""
var imitated_events = {
	'left': false,
	'right': false
}

var alive = true
var motion = Vector2(0,0)
var cooldown = 0
var start_time = 0
	
func imitate(record_data):
	record = record_data
	imitating = true
	start_time = OS.get_ticks_msec()
	set_physics_process(true)
	
func start():
	record = []
	set_physics_process(true)
	record.push_back({'t': OS.get_ticks_msec(), 'cmd': 'position', 'params': position})

func die():
	if alive:
	  alive = false
	  ray1.enabled = false
	  ray2.enabled = false
	  if not imitating:
	    game.die(record)
	  $Sfx/Death.play()
	  anim.play("Death")
	
	var blood = $Blood
	blood.emitting = true
	$Timer.start()
	record = {}

func controlled_player_process(delta):
	var in_air = not ray1.is_colliding() and not ray2.is_colliding()
	
	if cooldown <= 0:
		if Input.is_action_pressed("ui_accept"):
			
			record.push_back({'t': OS.get_ticks_msec(), 'cmd': 'fire', 'pos': position})
			cooldown = 0.1
			var shuriken = Shuriken.instance()
			shuriken.parent_ninja = self
			if sprite.flip_h:
				shuriken.direction = -1
			get_node("/root/Game").add_child(shuriken)
			$Sfx/Throw.play()
			shuriken.position = position + Vector2(20 * shuriken.direction, 0)
	else:
		cooldown -= delta
	
	if not in_air and Input.is_action_pressed("ui_up"):
		record.push_back({'t': OS.get_ticks_msec(), 'cmd': 'jump', 'pos': position})
		anim.play("Jump")
		$Sfx/Jump.stop()
		$Sfx/Jump.play()
		motion.y = JUMP_SPEED

	if Input.is_action_pressed("ui_right"):
		record.push_back({'t': OS.get_ticks_msec(), 'cmd': 'right', 'pos': position})
		if not in_air and anim.current_animation != "Run":
			anim.play("Run")
		motion.x = min(motion.x + SPEED * delta, SPEED * delta)
		sprite.flip_h = false

	if Input.is_action_pressed("ui_left"):
		record.push_back({'t': OS.get_ticks_msec(), 'cmd': 'left', 'pos': position})
		if not in_air and anim.current_animation != "Run":
			anim.play("Run")
		motion.x = max(motion.x - SPEED * delta, -SPEED * delta)
		sprite.flip_h = true
		
	elif !Input.is_action_pressed("ui_right"):
		record.push_back({'t': OS.get_ticks_msec(), 'cmd': 'stop', 'pos': position})
		motion.x = 0
		if anim.is_playing():
		  anim.stop()
		
func recorded_player_process(delta):
	if record.size() == 0:
		print("No record...")
		return
		
	var in_air = not ray1.is_colliding() and not ray2.is_colliding()
		
	var current_time = OS.get_ticks_msec() - start_time
	var next_action = record[0]
	print("Current action: " + str(next_action))
	
	if next_action['t'] >= current_time:
		var cmd = next_action['cmd']
		
		var params = null 
		if next_action.has('params'):
			params = next_action['params']
		
		var pos    = null 
		if next_action.has('pos'):
			pos = next_action['pos']
		
		if cmd == 'position':
			position = params
		elif pos:
			position = pos
			
		if cmd == 'left':
			imitated_events['left'] = true
			imitated_events['right'] = false

		if cmd == 'right':
			imitated_events['left'] = false
			imitated_events['right'] = true
		
		if cmd == 'stop':
			imitated_events['left'] = false
			imitated_events['right'] = false

		if cmd == 'fire':
			var shuriken = Shuriken.instance()
			shuriken.parent_ninja = self
			if sprite.flip_h:
				shuriken.direction = -1
			get_node("/root/Game").add_child(shuriken)
			$Sfx/Throw.play()
			shuriken.position = position + Vector2(20 * shuriken.direction, 0)
			
		if cmd == 'jump':
			anim.play("Jump")
			$Sfx/Jump.stop()
			$Sfx/Jump.play()
			motion.y = JUMP_SPEED
			
		if cmd == 'stop':
			motion.x = 0
			if anim.is_playing():
				anim.stop()

			
	if imitated_events['left']:
		if not in_air and anim.current_animation != "Run":
			anim.play("Run")
		motion.x = max(motion.x - SPEED * delta, -SPEED * delta)
		sprite.flip_h = true
			
	if imitated_events['right']:
		if not in_air and anim.current_animation != "Run":
			anim.play("Run")
		motion.x = min(motion.x + SPEED * delta, SPEED * delta)
		sprite.flip_h = false
		
	record.remove(0)
	
		
func _physics_process(delta):
	motion.y += GRAVITY * delta
	
	if !alive:
		motion = move_and_slide(motion)
		return
		
	if imitating:
		recorded_player_process(delta)
	else:
		controlled_player_process(delta)
		         
	motion = move_and_slide(motion)

func _on_Timer_timeout():
	$Blood.emitting = false