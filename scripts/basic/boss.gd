extends CharacterBody2D

@export var health : float = 100
@export var stamina: float = 100
@export var speed: float = 100
@export var jump_velocity: float = -300
@export var damage: float = 20.0

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var attack_coll = $Area2D/CollisionShape2D2
@onready var player_camera = $PlayerCamera

var max_health: float = 100
var max_stamina: float = 100.0

var direction: float
var attacking = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var attack_count = 0
var combo_timer = 0.8
var combo_active = false


func _ready() -> void:
	max_health = health
	max_stamina = stamina
	pass


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if stamina < 100 and direction == 0:
		stamina += 0.15
# The Functions
	move()
	jump()
	Attack()
	animation()

	move_and_slide()

# -----------------------------------
# Movement
# -----------------------------------
func move():
	direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
		$Marker2D.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

# -----------------------------------
# Jump
# -----------------------------------
func jump():
	if stamina > 10 and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		$jump.play()
		stamina -= 10

# -----------------------------------
#Attack
# -----------------------------------
func Attack():
	if stamina > 20 and Input.is_action_just_pressed("attack") and !attacking:
		attack_count += 1

		if attack_count == 1:
			start_attack1()
			combo_active = true
			await get_tree().create_timer(combo_timer).timeout
			combo_active = false

			# إذا ماضغطش ثاني ضغطة، نصفر الكومبو
			if attack_count == 1:
				attack_count = 0
				return

		elif attack_count == 2 and combo_active:
			start_attack2()
			attack_count = 0

func start_attack1():
	attacking = true
	stamina -= 5
	$attack.play()
	anim.play("attack1")
	await anim.animation_finished
	attacking = false

func start_attack2():
	attacking = true
	stamina -= 5
	$attack.play()
	anim.play("attack2")
	await anim.animation_finished
	attacking = false

# -----------------------------------
# hit player
# -----------------------------------
func hit(amount: int):
	if health <= 0:
		return # اللاعب ميت بالفعل
	
	health -= amount

	if health <= 0:
		die()

# -----------------------------------
# Dead
# -----------------------------------
func die():
	anim.play("dead")
	set_physics_process(false)
	await anim.animation_finished
	get_tree().reload_current_scene()

# -----------------------------------
# the animations
# -----------------------------------
func animation():
	if health <= 0:
		return
	
	if attacking:
		return
	
	if not is_on_floor():
		if velocity.y < 0:
			anim.play("jump")
		else:
			anim.play("fall")
	elif direction != 0:
		anim.play("run")
	else:
		anim.play("idle")

# -----------------------------------
# Animation finished
# -----------------------------------
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in ["attack1", "attack2"]:
		attacking = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("hit"):
		body.hit(damage)
		print("enemy entred the area")
	else:
		print("enemy not ontred the area")
