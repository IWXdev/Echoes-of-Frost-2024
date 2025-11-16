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

var current_pulse_tween: Tween = null

var player_node: Node = null 
var is_pulsating = false

# vars pulse
const LOW_HEALTH_THRESHOLD_PERCENT = 20.0
const PULSE_MIN_ALPHA = 0.05 # minimon
const PULSE_MAX_ALPHA = 0.53 # maximon
const PULSE_DURATION = 0.6  #pulse time

func _ready():
	# (Player  Root)
	player_node = get_tree().root.get_node_or_null("Game/samourai")
	
	red_overlay.modulate.a = 0.0
	
	center_message_label.hide()
	
	update_player_name()
	
	if player_node:
		health_bar.max_value = player_node.max_health 
		stamina_bar.max_value = player_node.max_stamina 
	else:
		print("WARNING: Player node not found! Health/Stamina bars will not update.")
		health_bar.hide()
		stamina_bar.hide()
	
	var target_method = Callable(self, "on_level_up")
	if GlobalSettings.is_connected("level_up", target_method): # ⬅️ فحص على GlobalSettings باستخدام اسم الإشارة "level_up"
		return
	GlobalSettings.connect("level_up", target_method) # ⬅️ ربط على GlobalSettings باستخدام اسم الإشارة "level_up"
	update_xp_display()
   

func on_level_up(_new_level):
	# ⬅️ هذه الدالة تعمل فقط عند Level Up
	update_xp_display() # تحديث الـ Bars
	print("HUD received Level Up signal!")
	# هنا يمكنك إضافة مؤثرات بصرية كبيرة (Visual effects)
	animate_center_message("Level Up Level " + str(_new_level) + "!")

func animate_center_message(message: String):
	var label = center_message_label
	label.text = message
	label.modulate.a = 1.0 # إظهار فوري
	label.scale = Vector2(0.5, 0.5) # نبدأ من حجم صغير
	label.show()
	
	var tween = create_tween()
	
	# 1. التكبير السريع مع اهتزاز بسيط
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
	# 2. الرجوع للحجم العادي مع إظهار نهائي
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.2)
	
	# 3. الانتظار لمدة كافية
	tween.tween_interval(1.0) 
	
	# 4. الاختفاء التدريجي
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	
	await tween.finished
	label.hide()

func update_player_name():
	player_name_hud_label.text = GlobalSettings.player_name

func _process(_delta):
	# update Bars FPS
	update_xp_display()
	if player_node:
		health_bar.value = player_node.health
		stamina_bar.value = player_node.stamina
		var health_percentage = (player_node.health / player_node.max_health) * 100.0
		if health_percentage <= LOW_HEALTH_THRESHOLD_PERCENT:
			if not is_pulsating:
				start_pulse()
		else:
			if is_pulsating:
				stop_pulse()

func update_xp_display():
	xp_bar.max_value = GlobalSettings.xp_to_next_level
	xp_bar.value = GlobalSettings.player_xp
	level_label.text = "L E V E L :  " + str(GlobalSettings.player_level)
	var current_xp = GlobalSettings.player_xp
	var next_xp = GlobalSettings.xp_to_next_level
	xp_progress_label.text = str(current_xp) + "  /  " + str(next_xp) + "  XP"

func start_pulse():
	is_pulsating = true
	
	# 1. إنشاء مثيل جديد لـ Tween
	current_pulse_tween = create_tween()
	
	# 2. نضمن أن النبض يبدأ من الشفافية الدنيا
	red_overlay.modulate.a = PULSE_MIN_ALPHA
	
	# 3. إعداد النبض والتكرار
	current_pulse_tween.set_loops() # جعل الحركة تتكرر للأبد
	
	# الانتقال من الأدنى إلى الأقصى
	current_pulse_tween.tween_property(red_overlay, "modulate:a", PULSE_MAX_ALPHA, PULSE_DURATION) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
	# الانتقال من الأقصى إلى الأدنى
	current_pulse_tween.tween_property(red_overlay, "modulate:a", PULSE_MIN_ALPHA, PULSE_DURATION) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func stop_pulse():
	is_pulsating = false
	
	# إيقاف الـ Tween وحذفه
	if current_pulse_tween != null:
		current_pulse_tween.kill() # إيقاف وحذف الـ Tween
		current_pulse_tween = null
	
	# إخفاء التوهج بشكل فوري
	red_overlay.modulate.a = 0.0
