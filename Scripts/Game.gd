extends Node2D

var Player = preload("res://Components/Player.tscn")

var clones = []
var next_clone_idx = 0
var paused_time = 0
var paused = false
var max_coins = 0
var coins = 0
var game_began = false

var stats   = {
	"deaths": 0,
	"best_time": 99999,
	"time": 99999
}

var started = false
var last_checkpoint
var last_checkpoint_idx = -1
var start_time = 0
var time       = 0

func _ready():
	set_process_input(true)
	max_coins = $Collectables.get_child_count()
	$CanvasLayer/Control/Coins.text = "0 / " + str(max_coins) 

func _input(event):
	if event is InputEventKey:
		if not started and !event.pressed and (Input.is_action_pressed('ui_left') or Input.is_action_pressed('ui_right') or Input.is_action_pressed('ui_up')):
			set_process(true)
			$CanvasLayer/Control/Finished/Time.show()
			if not game_began:
			  start_time = OS.get_unix_time()
			  time = 0
			  game_began = true
			
			started = true
			$Player.start()
			#if clones.size() > 0:
			#  $SpawnTimer.start()
		if event.pressed and Input.is_key_pressed(KEY_R):
			get_tree().change_scene("res://Scenes/Game.tscn")
	
func _process(delta):
	if paused:
		paused_time += delta
	else:
	  var elapsed = OS.get_unix_time() - start_time - paused_time
	  var minutes = elapsed / 60
	  var seconds = elapsed % 60
	  var str_elapsed = "%02d:%02d" % [minutes, seconds]
	  $CanvasLayer/Control/Time.text = str_elapsed;
			
func coin_picked():
	$Coin.play()
	coins += 1
	$CanvasLayer/Control/Coins.text = str(coins) + " / " + str(max_coins)
	
			
func die(record):
	#clones.append(record)
	#if clones.size() > 6:
	#	clones.pop_front()
	#next_clone_idx = 0
	
	set_process(false)
	
	#for clone in $Clones.get_children():
	#	clone.queue_free()
		
	#for  shuriken in $Shurikens.get_children():
	#	shuriken.queue_free()
		
	stats['deaths'] += 1
	$CanvasLayer/Control/Deaths.text = str(stats['deaths'])
	$Timer.start()
	
func next_iteration():
	if started:
		started = false

		#for enemy in $Enemies.get_children():
		#	enemy.reincarnate()
					
		var dead_player = $Player
		var camera = $Player/Camera2D
		if dead_player:
			dead_player.remove_child(camera)
		remove_child(dead_player)
		$Corpses.add_child(dead_player)
		
		var player = Player.instance()
		add_child(player)

		if last_checkpoint:
			player.position = last_checkpoint.position
		else:
			player.position = $SpawnPosition.position
		player.add_child(camera)
		
func spawn_clone(records):
	var clone = Player.instance()
	$Clones.add_child(clone)
	clone.position = $SpawnPosition.position
	clone.imitate(records)

func _on_Timer_timeout():
	next_iteration()

func _on_SpawnTimer_timeout():
	if false and clones.size() > next_clone_idx:
		var clone = clones[next_clone_idx]
		spawn_clone(clone)
		next_clone_idx += 1
		
		if clones.size() > next_clone_idx:
			$SpawnTimer.wait_time = 2
			$SpawnTimer.start()

func checkpoint(point):
	if point.idx > last_checkpoint_idx:
		last_checkpoint = point

func _on_Exit_body_entered(body):
	if body.is_in_group("Player"):
		game_finished()
		
func game_finished():
	set_process(false)
	$FinishedSFX.play()
	$CanvasLayer/Control/Finished.show()
	$CanvasLayer/Control/Finished/Time.text = "Finished in " + $CanvasLayer/Control/Time.text + " with " + $CanvasLayer/Control/Deaths.text + " reincarnations"

func _on_Button_pressed():
	get_tree().change_scene("res://Scenes/Game.tscn")
	

func _on_Button2_pressed():
	get_tree().quit()