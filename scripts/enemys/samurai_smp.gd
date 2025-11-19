extends "res://scripts/basic/BaseEnemy.gd"


func attack() -> void:
	can_attack = false
	$attack.play()
	anim.play("attack")
	await get_tree().create_timer(0.5).timeout
	attack_coll.disabled = false

	await get_tree().create_timer(0.8).timeout
	attack_coll.disabled = true

	await get_tree().create_timer(1.0).timeout
	can_attack = true

func hit(amount: float, is_critical: bool):
	if health <= 0:
		return
	
	health -= amount
	healthbar.value = health
	anim.play("hit")
	# damage sceneر
	const DAMAGE_NUMBER_SCENE = preload("res://scenes/athers/damage_number.tscn")

	# 3.copy the scene
	var damage_instance = DAMAGE_NUMBER_SCENE.instantiate()

	get_parent().add_child(damage_instance)

	# 5. damage position
	damage_instance.global_position = self.global_position + Vector2(0, -15) # -15 px Y

	# 6. damage value
	damage_instance.setup_damage(amount, is_critical)
	if health <= 0:
		die()
