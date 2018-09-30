extends Node2D

var Player = preload("res://Components/Player.tscn")

var clones = []
var next_clone_idx = 0
var started = false
var stats   = {
	"deaths": 0,
	"best_time": 99999,
	"time": 99999
}


var last_checkpoint
var last_checkpoint_idx = -1
var start_time = 0
var time       = 0

func _ready():
	set_process_input(true)

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			set_process_input(false)
			set_process(true)
			start_time = OS.get_unix_time()
			time = 0
			started = true
			$CanvasLayer/Control/StartLabel.hide()
			$Player.start()
			#if clones.size() > 0:
			#  $SpawnTimer.start()
	
func _process(delta):
	var elapsed = OS.get_unix_time() - start_time
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	var str_elapsed = "%02d:%02d" % [minutes, seconds]
	$CanvasLayer/Control/Time.text = str_elapsed;
			
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
		set_process_input(true)

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
		$CanvasLayer/Control/StartLabel.show()

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