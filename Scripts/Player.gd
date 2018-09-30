extends KinematicBody2D

export var GRAVITY = 40 * 60
export var SPEED   = 30000
export var JUMP_SPEED  = -950

onready var sprite = $Sprite
onready var anim   = $AnimationPlayer
onready var ray1   = $RayLeft
onready var ray2   = $RayRight
onready var game   = get_node("/root/Game")
onready var shurikens_node = get_node("/root/Game/Shurikens")

var Shuriken = preload("res://Components/Shuriken.tscn")

var exploding = false
var shurikens = []
var record = []
var imitating = false
var imitating_cmd = ""
var prev_cmd
var imitated_events = {
	'left': false,
	'right': false
}

var alive = true
var motion = Vector2(0,0)
var cooldown = 0
var start_time = 0
var dead_hits = 3
	
func pick_coin():
	game.coin_picked()
	
func imitate(record_data):
	record = record_data
	imitating = true
	imitated_events = { 'left': false, 'right': false }
	start_time = OS.get_ticks_msec()
	set_physics_process(true)
	
func start():
	record = []
	start_time = OS.get_ticks_msec()
	record.push_back({'t': OS.get_ticks_msec() - start_time, 'c': 'position', 'params': position})
	set_physics_process(true)
	
func die():
	if alive:
	  $Light2D.queue_free()
	  alive = false
	  ray1.enabled = false
	  ray2.enabled = false
	  if not imitating:
	    game.die(record)
	  $Sfx/Death.play()
	  anim.play("Death")
		
	var blood = $Blood
	blood.emitting = true

	record = {}
	if dead_hits <= 0:
		queue_free()
		for shuriken in shurikens:
			shuriken.queue_free()
	else:
		$Timer.start()

func controlled_player_process(delta):
	var in_air = not ray1.is_colliding() and not ray2.is_colliding()
	
	if cooldown <= 0:
		if Input.is_action_pressed("ui_accept"):
			
			record.push_back({'t': OS.get_ticks_msec() - start_time, 'c': 'f'})
			cooldown = 0.1
			var shuriken = Shuriken.instance()
			shuriken.parent_ninja = self
			if sprite.flip_h:
				shuriken.direction = -1
			if shurikens_node:
			  shurikens_node.add_child(shuriken)
			anim.play("Attack")
			$Sfx/Throw.play()
			shuriken.position = position + Vector2(30 * shuriken.direction, -30)
	else:
		cooldown -= delta
	
	if not in_air and Input.is_action_pressed("ui_up"):
		record.push_back({'t': OS.get_ticks_msec() - start_time, 'c': 'j', 'pos': position})
		anim.play("Jump")
		$Sfx/Jump.stop()
		$Sfx/Jump.play()
		motion.y = JUMP_SPEED

	if Input.is_action_pressed("ui_right"):
		if prev_cmd != 'r':
			record.push_back({'t': OS.get_ticks_msec() - start_time, 'c': 'r', 'pos': position})
			prev_cmd = 'r'
			
		if not in_air and anim.current_animation != "Run":
			anim.play("Run")
		motion.x = min(motion.x + SPEED * delta, SPEED * delta)
		sprite.flip_h = false

	if Input.is_action_pressed("ui_left"):
		if prev_cmd != 'l':
			record.push_back({'t': OS.get_ticks_msec() - start_time, 'c': 'l', 'pos': position})
			prev_cmd = 'l'
			
		if not in_air and anim.current_animation != "Run":
			anim.play("Run")
		motion.x = max(motion.x - SPEED * delta, -SPEED * delta)
		sprite.flip_h = true
		
	elif !Input.is_action_pressed("ui_right"):
		if prev_cmd != 's':
			record.push_back({'t': OS.get_ticks_msec() - start_time, 'c': 's', 'pos': position})
			prev_cmd = 's'
		motion.x = 0
		if anim.is_playing():
		  anim.stop()
		
	
func recorded_player_process(delta):
	if record.size() == 0:
		if not exploding:
		  exploding = true
		  explode()
		return
			
	var current_time = OS.get_ticks_msec() - start_time
	var next_action = record[0]
	
	
	if next_action['t'] <= current_time:
		print(str(current_time) + ": Current action: " + str(next_action))
		var cmd = next_action['c']
		next_action = record.pop_front()
		
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
			
		if cmd == 'l':
			imitated_events['left'] = true
			imitated_events['right'] = false

		if cmd == 'r':
			imitated_events['left'] = false
			imitated_events['right'] = true
		
		if cmd == 's':
			imitated_events['left'] = false
			imitated_events['right'] = false

		if cmd == 'f':
			var shuriken = Shuriken.instance()
			shuriken.parent_ninja = self
			if sprite.flip_h:
				shuriken.direction = -1
			get_node("/root/Game").add_child(shuriken)
			$Sfx/Throw.play()
			shuriken.position = position + Vector2(20 * shuriken.direction, 0)
			
		if cmd == 'j':
			anim.play("Jump")
			$Sfx/Jump.stop()
			$Sfx/Jump.play()
			motion.y = JUMP_SPEED
			
		if cmd == 's':
			motion.x = 0
			if anim.is_playing():
				anim.stop()
			
	if imitated_events['left']:
		if anim.current_animation != "Run":
			anim.play("Run")
		motion.x = max(motion.x - SPEED * delta, -SPEED * delta)
		sprite.flip_h = true
			
	if imitated_events['right']:
		if anim.current_animation != "Run":
			anim.play("Run")
		motion.x = min(motion.x + SPEED * delta, SPEED * delta)
		sprite.flip_h = false
		
	
		
func _physics_process(delta):
	if game.paused:
		return
		
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
	$DisableTimer.start()
	#set_physics_process(false)
	
func explode():
	die()
			

func _on_DisableTimer_timeout():
	set_physics_process(false)
	