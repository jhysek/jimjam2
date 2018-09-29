extends Node2D

var Player = preload("res://Components/Player.tscn")

var clones = []
var started = false

func _ready():
	set_process_input(true)

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			set_process_input(false)
			started = true
			$CanvasLayer/Control/StartLabel.hide()
			$Player.start()
			
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
	



func _on_Timer_timeout():
	next_iteration()