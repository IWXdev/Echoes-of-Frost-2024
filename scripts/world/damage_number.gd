extends Node2D


func setup_damage(value, is_critical):
	$Label.text = "-" + str(value)
	$".".modulate = Color.YELLOW
	# change color if attack == critical
	if is_critical:
		$".".modulate = Color.RED
		print("Hello")
	$AnimationPlayer.play("FloatAndFade")

func _on_animation_finished(anim_name):
	if anim_name == "FloatAndFade":
		queue_free()
