extends Control

signal splash_finished 

func _ready() -> void:
	$AnimationPlayer.play("Intro")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Intro":
		emit_signal("splash_finished") 
	# يمكنك حذف المشهد نفسه بعد إطلاق الإشارة
		queue_free()
