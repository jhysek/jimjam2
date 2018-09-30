extends Node2D

var Player = preload("res://Components/Player.tscn")

var clones = []
var started = false
var stats   = {
	"deaths": 0,
	"best_time": 99999,
	"time": 0
}

func _ready():
	set_process_input(true)

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			set_process_input(false)
			started = true
			$CanvasLayer/Control/StartLabel.hide()
			$Player.start()
			if clones.size() > 0:
			  $SpawnTimer.start()
			
func die(record):
	clones.append(record)
	$Timer.start()
	
func next_iteration():
	if started:
		started = false
		set_process_input(true)
		
		var dead_player = $Player
		var camera = $Player/Camera2D
		dead_player.remove_child(camera)
		remove_child(dead_player)
		$Corpses.add_child(dead_player)
		
		var player = Player.instance()
		add_child(player)

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
	if clones.size() > 0:
		var clone = clones.pop_front()
		spawn_clone(clone)
		
		if clones.size() > 0:
			$SpawnTimer.wait_time = 2
			$SpawnTimer.start()
		
