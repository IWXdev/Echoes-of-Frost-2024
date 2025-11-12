
extends "res://scripts/basic/BaseEnemy.gd"


func attack() -> void:
	can_attack = false
	$attack.play()
	anim.play("attack")
	# نفعّل الاصطدام فقط لحظة الضربة
	await get_tree().create_timer(0.65).timeout
	attack_coll.disabled = false

	await get_tree().create_timer(0.75).timeout
	attack_coll.disabled = true

	await get_tree().create_timer(1.0).timeout
	can_attack = true
