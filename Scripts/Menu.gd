extends Node2D

var paused = false

func _ready():
	set_process_input(true)

func _input(event):
	if event is InputEventKey:
		get_tree().change_scene("res://Scenes/Game.tscn")
