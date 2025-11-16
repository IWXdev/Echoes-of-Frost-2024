extends Node2D


func setup_damage(value, is_critical):
	$Label.text = "-" + str(value)
	
	# يمكنك تغيير لون النص هنا بناءً على إذا كان ضربة حرجة
	# if is_critical:
	#     $Label.modulate = Color.RED

	$AnimationPlayer.play("FloatAndFade")

func _on_animation_finished(anim_name):
	if anim_name == "FloatAndFade":
		queue_free()
