# HUD.gd (Control)
extends Control

@onready var health_bar = $healthbar 
@onready var stamina_bar = $stamina
@onready var red_overlay = $damag_player
@onready var player_name_hud_label = $PlayerNameLabel
@onready var xp_bar = $XPBar
@onready var level_label = $LevelLabel
@onready var xp_progress_label = $XPBar/XPProgressLabel
@onready var center_message_label = $CenterMessageLabel
@onready var level_up_menu = $LevelUpMenu
#>>>>>
@onready var damage =$HBoxContainer/damage/value
@onready var crit =$HBoxContainer/crit_chance/value
@onready var speed = $HBoxContainer/speed/value
@onready var max_health = $HBoxContainer/max_health/value
#<<<<<
var current_pulse_tween: Tween = null

var player_node: Node = null 
var is_pulsating = false

# vars pulse
const LOW_HEALTH_THRESHOLD_PERCENT = 20.0
const PULSE_MIN_ALPHA = 0.05 # minimon
const PULSE_MAX_ALPHA = 0.53 # maximon
const PULSE_DURATION = 0.6  #pulse time

func _ready():
	
	# GlobalSettings
	GlobalSettings.open_upgrade_menu.connect(Callable(level_up_menu, "open_menu"))
	
	# (Player  Root)
	player_node = get_tree().root.get_node_or_null("Game/samourai")
	
	red_overlay.modulate.a = 0.0
	
	center_message_label.hide()
	
	update_player_name()
	
	if player_node:
		health_bar.max_value = GlobalSettings.player_max_health
		stamina_bar.max_value = GlobalSettings.player_max_stamina
	else:
		print("WARNING: Player node not found! Health/Stamina bars will not update.")
		health_bar.hide()
		stamina_bar.hide()
	
	var target_method = Callable(self, "on_level_up")
	if GlobalSettings.is_connected("level_up", target_method):
		return
	GlobalSettings.connect("level_up", target_method)
   

func on_level_up(_new_level):
	# this func work just if Level Up
	update_xp_display() # updata Bars
	print("HUD received Level Up signal!")
	# (Visual effects)
	animate_center_message("Level Up Level " + str(_new_level) + " !")

func animate_center_message(message: String):
	var label = center_message_label
	label.text = message
	label.modulate.a = 1.0
	label.scale = Vector2(0.5, 0.5)
	label.show()
	
	var tween = create_tween()
	
	# 1.fast zoom and small vebration
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
	# 2.back to global scale
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.2)
	
	# 3. white 1 s
	tween.tween_interval(1.0) 
	
	# 4.hide sbs
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	
	await tween.finished
	label.hide()

func update_player_name():
	player_name_hud_label.text = GlobalSettings.player_name

func _process(_delta):
	ui_skells()
	# update Bars FPS
	update_xp_display()
	if player_node:
		health_bar.value = player_node.health
		stamina_bar.value = player_node.stamina
		var health_percentage = (player_node.health / GlobalSettings.player_max_health) * 100.0
		if health_percentage <= LOW_HEALTH_THRESHOLD_PERCENT:
			if not is_pulsating:
				start_pulse()
		else:
			if is_pulsating:
				stop_pulse()

func update_xp_display():
	xp_bar.max_value = GlobalSettings.xp_to_next_level
	xp_bar.value = GlobalSettings.player_xp
	level_label.text = "L E V E L  :  " + str(GlobalSettings.player_level)
	var current_xp = GlobalSettings.player_xp
	var next_xp = GlobalSettings.xp_to_next_level
	xp_progress_label.text = str(current_xp) + "  /  " + str(next_xp) + "  XP"

func start_pulse():
	is_pulsating = true
	
	current_pulse_tween = create_tween()
	
	red_overlay.modulate.a = PULSE_MIN_ALPHA
	
	#loop 
	current_pulse_tween.set_loops() 
	
	#min to max
	current_pulse_tween.tween_property(red_overlay, "modulate:a", PULSE_MAX_ALPHA, PULSE_DURATION) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
	#max to min
	current_pulse_tween.tween_property(red_overlay, "modulate:a", PULSE_MIN_ALPHA, PULSE_DURATION) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func stop_pulse():
	is_pulsating = false
	
	# stop the Tween ana delete
	if current_pulse_tween != null:
		current_pulse_tween.kill() # إيقاف وحذف الـ Tween
		current_pulse_tween = null
	
	#stop the pulse
	red_overlay.modulate.a = 0.0
	
func ui_skells():
	damage.text = str(GlobalSettings.player_damage_base)
	crit.text = str(GlobalSettings.player_crit_chance)
	speed.text = str(GlobalSettings.player_speed)
	max_health.text = str(GlobalSettings.player_max_health)
