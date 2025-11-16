extends Node

# ✅ الأسماء صحيحة الآن بناءً على الصورة الأخيرة
@onready var current_level = $currentLevel
@onready var loading_screen = $Loading
@onready var player = $samourai
@onready var hud_node = $HUD
@onready var splash_screen = $splash
var saved_game_data: Dictionary = {}

func _ready():
	if player:
		player.hide()
		player.player_camera.enabled = false
	if hud_node:
		hud_node.hide()
	# التحقق من وجود النودز قبل ربط الإشارة
	if loading_screen and is_instance_valid(loading_screen):
		if not loading_screen.scene_loaded.is_connected(_on_scene_loaded):
			loading_screen.scene_loaded.connect(_on_scene_loaded)
		
		if splash_screen and is_instance_valid(splash_screen):
			splash_screen.splash_finished.connect(_on_splash_finished)
#		load_home()
	else:
		# 💡 هذا هو الكود اللي غادي يقوليك فين كاين الخطأ بالضبط
		print("Loading node not found! Check spelling in Game.tscn.")
#		get_tree().change_scene_to_file("res://scenes/UI/home.tscn")


func clear_level():
	# ✅ هذا السطر فيه خرابق، خاصنا نصلحوه بـ deferred
	for child in current_level.get_children():
		child.call_deferred("queue_free") # نصلحوا مشكل الـ busy


func load_home():
	if player:
		player.hide()
		player.player_camera.enabled = false
	if hud_node:
		hud_node.hide()
	if loading_screen and is_instance_valid(loading_screen):
		loading_screen.start_loading("res://scenes/UI/home.tscn")
		print("tama ta7mil home bi njah")



func load_level1():
	if player:
		player.show()
	if loading_screen and is_instance_valid(loading_screen):
		print("scene is laoding")
		loading_screen.start_loading("res://scenes/levels/level.tscn")
	else:
		print("scene not laoding")

func load_saved_game():
	
	saved_game_data = GlobalSettings.load_game() # ⬅️ تخزين البيانات هنا
	var level_path = saved_game_data.game.current_level if saved_game_data.has("game") else "res://scenes/UI/home.tscn"

	if player: player.show()

	if loading_screen and is_instance_valid(loading_screen):
		loading_screen.start_loading(level_path) 
	else:
		print("CRITICAL ERROR: Loading Screen not ready for saved game load.")

func _on_splash_finished():
	# 💡 هذا الكود يتم تنفيذه بعد انتهاء الرسوم المتحركة للشعار
	load_home()
	print("SplashScreen finished, starting Home scene load.")

func _on_scene_loaded(scene: PackedScene):
	clear_level()
	var new_scene = scene.instantiate()
	current_level.add_child(new_scene)
	if not saved_game_data.is_empty():
		# ✅ تطبيق بيانات الحفظ وتغيير الموقع
		var data = saved_game_data.player
		player.health = data.health
		player.stamina = data.stamina
		player.global_position = Vector2(data.pos_x, data.pos_y)
		
		# ⚠️ تنظيف الـ Flag (ضروري)
		saved_game_data = {} 
	
		# ✅ تفعيل الكاميرا والـ HUD
		player.player_camera.enabled = true
		hud_node.show()
	# 💡 الخطوة الجديدة: تحديد مكان Player
	elif player.visible: # إذا كان اللاعب ظاهر (يعني رآه Level)
		set_player_spawn(new_scene) # ندوزو المشهد الجديد باش نلقاو فيه Spawn Point 
		if player.player_camera:
			player.player_camera.enabled = true 
		if hud_node:
			hud_node.show()
	loading_screen.hide()
	await get_tree().process_frame


func set_player_spawn(level_scene: Node) -> void:
	# 1. نبحث عن نود SpawnPoint داخل المشهد اللي تحمل
	# ⚠️ ضروري تكون نود Marker2D وسميتها SpawnPoint في Level.tscn
	var spawn_point = level_scene.get_node_or_null("SpawnPoint") 
	
	if spawn_point:
		# 2. نحرك اللاعب (اللي هو $Player) لمكان Spawn Point
		player.global_position = spawn_point.global_position
	else:
		print("WARNING: SpawnPoint not found in the current level!")
		# كحل احتياطي، نقدرو نحطوه فـ (0, 0)
