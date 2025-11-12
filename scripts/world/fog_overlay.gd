extends Sprite2D

@export var speed = 35.0
 # i have sum broblems her i need fixit
func _ready() -> void:
	position.x = 0
	
func _process(delta):
	position.x += speed * delta
	if position.x > 3528:
		position.x = 0
