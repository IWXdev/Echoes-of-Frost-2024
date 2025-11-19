extends Label

@export var float_speed: float = 80.0
@export var fade_duration: float = 0.8

func _ready():
	# 1. up anim
	var move_tween = create_tween()
	# up -= 12px
	move_tween.tween_property(self, "position:y", position.y - 12, float_speed / 100.0) 
	
	# hide
	var fade_tween = create_tween()
	fade_tween.tween_interval(0.2) # wite 0.2 s
	fade_tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	
	# 3. delet 
	await fade_tween.finished
	queue_free()
