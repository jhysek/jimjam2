extends Area2D


func _on_Deathzone_body_entered(body):
	if body.is_in_group("Player"):
		body.motion = Vector2(0,0)
		body.die()