# HUD.gd (مربوط بـ Control - الجذر الفعلي)
extends Control # ⬅️ التصحيح هو أننا نرجعوها Control

# 🔗 تعريف النودات
# كلشي كاين مباشرة تحت Control، يعني كنستعملو مسار مباشر
@onready var health_bar = $healthbar 
@onready var stamina_bar = $stamina
@onready var red_overlay = $damag_player
@onready var player_name_hud_label = $PlayerNameLabel
var current_pulse_tween: Tween = null

var player_node: Node = null 
var is_pulsating = false

# ⚙️ متغيرات التحكم في النبض
const LOW_HEALTH_THRESHOLD_PERCENT = 20.0
const PULSE_MIN_ALPHA = 0.05 # أدنى شفافية (إضاءة خفيفة)
const PULSE_MAX_ALPHA = 0.53 # أقصى شفافية (أقصى إضاءة)
const PULSE_DURATION = 0.6  # مدة النبضة الواحدة بالثواني

func _ready():
	# 💡 ربط الـ Player الثابت (المسار الصحيح هو من Root)
	player_node = get_tree().root.get_node_or_null("Game/samourai")
	
	red_overlay.modulate.a = 0.0
	
	update_player_name()
	
	if player_node:
		# إعداد الـ Bars الأولية
		health_bar.max_value = player_node.max_health 
		stamina_bar.max_value = player_node.max_stamina 
	else:
		print("WARNING: Player node not found! Health/Stamina bars will not update.")
		health_bar.hide()
		stamina_bar.hide()

func update_player_name():
	player_name_hud_label.text = GlobalSettings.player_name

func _process(_delta):
	# تحديث الـ Bars في كل إطار
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



func start_pulse():
	is_pulsating = true
	
	# 1. إنشاء مثيل جديد لـ Tween
	# نستخدم create_tween() المتوفرة على نود الـ HUD (التي هي Control)
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
