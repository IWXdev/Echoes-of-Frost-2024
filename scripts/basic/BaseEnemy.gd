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
	
	if distance <= attack_range and can_attack:
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
			var target_scale_x = 1 if direction.x >= 0 else -1
			$Marker2D.scale.x = target_scale_x
		else:
			anim.play("idle")
	else:
		velocity = Vector2.ZERO
		anim.play("idle")
# Enemy Attacking
func attack() -> void:
	pass
# enemy hit

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
