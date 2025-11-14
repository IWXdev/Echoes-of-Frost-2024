
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

func hit(amount: int):
	if health <= 0:
		return # اللاعب ميت بالفعل
	
	health -= amount
	healthbar.value = health
	anim.play("hit")
	# 2. تحميل مشهد رقم الضرر
	const DAMAGE_NUMBER_SCENE = preload("res://scenes/athers/damage_number.tscn")

# 3. إنشاء نسخة من المشهد
	var damage_instance = DAMAGE_NUMBER_SCENE.instantiate()

# 4. إضافة النسخة إلى المشهد الرئيسي (أو المشهد الذي يتواجد فيه العدو)
	get_parent().add_child(damage_instance)

# 5. ضبط موقع الرقم ليكون فوق العدو
	damage_instance.global_position = self.global_position + Vector2(0, -70) # -50 ليكون فوق العدو قليلاً

# 6. تمرير قيمة الضرر وتشغيل الحركة
	damage_instance.setup_damage(amount, false) # false لعدم وجود ضربة حرجة كمثال
	if health <= 0:
		die()
