extends CharacterBody2D

var health : float = 100
var stamina: float = 100
@export var jump_velocity: float = -300
@export var wall_slide_speed = 50
@export var wall_jump_force = Vector2(200, -300)

@onready var global_settings = GlobalSettings
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var attack_coll = $Marker2D/Sprite2D/Area2D/CollisionShape2D2
@onready var player_camera = $PlayerCamera

var wall_dir = 0 
var on_wall = false


var direction: float
var attacking = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var attack_count = 0
var combo_timer = 0.8
var combo_active = false
var is_dead : bool = false

signal died

func _ready() -> void:
	global_settings.player_max_health = health
	global_settings.player_max_stamina = stamina
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
	check_wall()


	if on_wall and not is_on_floor() and velocity.y > 0:
		velocity.y = wall_slide_speed


	if stamina > 10 and on_wall and Input.is_action_just_pressed("jump"):
			velocity = Vector2(-wall_dir * wall_jump_force.x, wall_jump_force.y)
			stamina -= 10

	animation()
	move_and_slide()


# Movement

func move():
	if anim.current_animation == "attack":
		return
	
	
	direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * GlobalSettings.player_speed
		$Marker2D.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, GlobalSettings.player_speed)

# Jump
func jump():
	if stamina > 10 and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		$jump.play()
		stamina -= 10

#Attack
func Attack():
	if stamina > 20 and Input.is_action_just_pressed("attack") and !attacking:
		attack_count += 1

		if attack_count == 1:
			start_attack1()
			combo_active = true
			await get_tree().create_timer(combo_timer).timeout
			combo_active = false

			# if input ont double click 0 combat
			if attack_count == 1:
				attack_count = 0
				return

		elif attack_count == 2 and combo_active:
			start_attack2()
			attack_count = 0

func heal(percentage: float):
	# 1. calcule the health
	var amount = global_settings.player_max_health * percentage
	# 2. add the heal to the health
	health += amount
	# 3. pluse health < max_health
	health = min(health, global_settings.player_max_health)
	
	print("Player healed for: ", amount)
	
	# (VFX)

func get_head_position() -> Vector2:
	# +50 player positon - 12px
	return global_position + Vector2(0, -12)

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

# hit player
func hit(amount: int):
	anim.play("hit")
	if health <= 0:
		return
	health -= amount

	if health <= 0 and not is_dead:
		die()

# Dead
func die():
	is_dead = true
	anim.play("dead")
	set_process_input(false)
	set_physics_process(false)
	await anim.animation_finished
	died.emit()

# Check wall
func check_wall():
	on_wall = false
	wall_dir = 0

	if direction != 0 and not is_on_floor():
		var space_state = get_world_2d().direct_space_state


		var ray = PhysicsRayQueryParameters2D.new()
		ray.from = global_position
		ray.to = global_position + Vector2(direction * 8, 0)
		ray.exclude = [self]

		var result = space_state.intersect_ray(ray)
		if result:
			on_wall = true
			wall_dir = direction


# the animations
func animation():
	if health <= 0:
		return
	
	if attacking:
		return
	if anim.current_animation == "hit":
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

# Animation finished
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in ["attack1", "attack2"]:
		attacking = false

func get_calculated_damage() -> Dictionary:
	# 1.git the player_damage_base
	var final_damage = global_settings.player_damage_base
	var is_critical = false
	
	# 2.(Critical Hit Check)
	# randf()
	if randf() < global_settings.player_crit_chance:
		final_damage *= global_settings.player_crit_multiplier
		is_critical = true
		print("CRITICAL HIT APPLIED!")
		# (add sound or somting)
		
	return {"damage": final_damage, "is_critical": is_critical}
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("hit"):
		# 1. calcule the final damage
		var result = get_calculated_damage()   
		# 2.applice the damage to enemy
		body.hit(result.damage, result.is_critical)
