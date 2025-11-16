extends Label

@export var float_speed: float = 80.0
@export var fade_duration: float = 0.8

func _ready():
	# 💡 نبدأ الحركة والاختفاء مباشرة
	
	# 1. حركة الصعود
	var move_tween = create_tween()
	# نحركه للأعلى بمقدار 12 بكسل
	move_tween.tween_property(self, "position:y", position.y - 12, float_speed / 100.0) 
	
	# 2. الاختفاء
	var fade_tween = create_tween()
	fade_tween.tween_interval(0.2) # انتظار قليل
	fade_tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	
	# 3. الحذف الذاتي بعد الانتهاء
	await fade_tween.finished
	queue_free()
