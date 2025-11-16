
extends "res://scripts/basic/BaseEnemy.gd"


func attack() -> void:
	can_attack = false
	$attack.play()
	anim.play("attack")
	# activate the collision at the moment of attack
	await get_tree().create_timer(0.65).timeout
	attack_coll.disabled = false

	await get_tree().create_timer(0.75).timeout
	attack_coll.disabled = true

	await get_tree().create_timer(1.0).timeout
	can_attack = true

func hit(amount: int):
	if health <= 0:
		return # the player ready death
	
	health -= amount
	healthbar.value = health
	anim.play("hit")
	# Load Damage number 
	const DAMAGE_NUMBER_SCENE = preload("res://scenes/athers/damage_number.tscn")

# create copy scene
	var damage_instance = DAMAGE_NUMBER_SCENE.instantiate()

#add copy to enemy scene
	get_parent().add_child(damage_instance)

# Number position 
	damage_instance.global_position = self.global_position + Vector2(0, -70)

# damage value
	damage_instance.setup_damage(amount, false) # false if critcale 
	if health <= 0:
		die()
