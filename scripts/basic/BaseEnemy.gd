extends CharacterBody2D

@export var health : float = 100.0
@export var speed: float = 50.0
@export var detection_range: float = 200.0
@export var attack_range: float = 40.0
@export var damage: float = 10.0

@onready var attack_coll: CollisionShape2D = $Marker2D/Golmn/Area2D/CollisionShape2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var healthbar = $healthbar
@onready var player = get_tree().get_first_node_in_group("player")

var can_attack = true


func _ready() -> void:
	attack_coll.disabled = true
	healthbar.value = health


func _physics_process(_delta: float) -> void:
	if not player:
		return
	
	move()
	move_and_slide()

# Enemy move 
func move():
	if anim.current_animation == "attack":
		return  # ما نحركوش أثناء الهجوم
	if anim.current_animation == "hit":
		return 

	var distance = global_position.distance_to(player.global_position)
	
	if distance < attack_range and can_attack:
		velocity = Vector2.ZERO
		attack()
	elif distance < detection_range:
		agent.target_position = player.global_position
		var next_path_pos = agent.get_next_path_position()
		var direction = (next_path_pos - global_position).normalized()
		
		velocity = direction * speed
		
		if direction.length() > 0:
			anim.play("walk")
			$walk.play()
			$Marker2D/Golmn.flip_h = direction.x < 0
		else:
			anim.play("idle")
	else:
		velocity = Vector2.ZERO
		anim.play("idle")
# Enemy Attacking
func attack() -> void:
	pass
# enemy hit
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
	damage_instance.global_position = self.global_position + Vector2(0, -65) # -50 ليكون فوق العدو قليلاً

# 6. تمرير قيمة الضرر وتشغيل الحركة
	damage_instance.setup_damage(amount, false) # false لعدم وجود ضربة حرجة كمثال
	if health <= 0:
		die()

# Enemy Die
func die():
	anim.play("dead")
	set_physics_process(false)
	await anim.animation_finished
	queue_free()

#Palyer Hit
func _on_area_2d_body_entered(body: Node2D) -> void:
	if not attack_coll.disabled and body.is_in_group("player") and body.has_method("hit"):
		body.hit(damage)
