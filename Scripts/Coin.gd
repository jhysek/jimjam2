extends Area2D

var timeout = 0.1
var frame   = 0
onready var sprite = $Sprite

func _ready():
	set_process(true)

func _process(delta):
	if timeout > 0:
		timeout -= delta
	else:
		timeout = 0.1
		next_frame()
		
func next_frame():
	frame = (frame + 1) % 8
	sprite.region_rect =  Rect2(32 * frame, 0, 32, 32)

func _on_Coin_body_entered(body):
	if body.is_in_group("Player"):
		# Pick sound
		body.pick_coin()
		queue_free()