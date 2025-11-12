extends Node2D


# دالة لضبط قيمة الرقم وتشغيل الحركة
func setup_damage(value, is_critical):
	$Label.text = "-" + str(value)
	
	# يمكنك تغيير لون النص هنا بناءً على إذا كان ضربة حرجة
	# if is_critical:
	#     $Label.modulate = Color.RED

	# تشغيل الحركة مباشرة عند الإنشاء
	$AnimationPlayer.play("FloatAndFade")

# دالة الحذف الذاتي (يتم استدعاؤها في نهاية الـ AnimationPlayer)
func _on_animation_finished(anim_name):
	if anim_name == "FloatAndFade":
		queue_free() # هذه الدالة تحذف النود ومشاهده تلقائياً
