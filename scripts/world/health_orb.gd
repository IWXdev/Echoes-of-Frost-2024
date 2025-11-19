extends Area2D

@export var healing_percentage: float = 0.25 # 25% Max Health


func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	$Timer.start()
# call yhis func if player tike the items 
func _on_body_entered(body: Node2D):
	# 1. check is this player 
	if body.is_in_group("player") and body.has_method("heal"):
		print(body.name)
		$AnimatedSprite2D.play("take")
		# 2. call Heal func Player.gd
		body.heal(healing_percentage) 
		await $AnimatedSprite2D.animation_finished
		# 3. delete the item
		queue_free()


func _on_timer_timeout() -> void:
	$AnimatedSprite2D.play("take")
	await $AnimatedSprite2D.animation_finished
	queue_free()
