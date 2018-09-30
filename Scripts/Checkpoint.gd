extends Area2D

export var idx = 0


func _on_Checkpoint_body_entered(body):
	if body.is_in_group("Player"):
		var game = get_node("/root/Game")
		game.checkpoint(self)