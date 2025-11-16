extends Control

# ✅ متغير محلي لتفادي الضغطات المتعددة
var is_menu_busy: bool = false
@onready var continue_button = $VBoxContainer/Continue
@onready var player_name_label = $PlayerNameLabel
var has_save = GlobalSettings.has_saved_game()

func _ready() -> void:
	$AnimationPlayer.play("star")
	if has_save:
		continue_button.show()
	else:
		continue_button.hide()
	display_player_name()
	if not has_save and GlobalSettings.player_name == "":
		call_deferred("show_name_popup") # تأجيل الظهور حتى يتم تحميل كل شيء

func display_player_name():
	# ⬅️ عرض الاسم المحفوظ
	player_name_label.text = GlobalSettings.player_name

func show_name_popup():
	# ⬅️ تحميل مشهد النافذة (تأكد من المسار)
	var popup_scene = load("res://scenes/UI/player_name_popup.tscn")
	var popup = popup_scene.instantiate()
	add_child(popup)
	
	# ⬅️ ربط الإشارة لي كترجع لينا الاسم
	popup.name_entered.connect(Callable(self, "_on_name_entered"))


func _on_name_entered(player_name_input):
	# ⬅️ يتم المناداة على هاد الدالة ملي اللاعب يدخل الاسم
	GlobalSettings.player_name = player_name_input
	GlobalSettings.save_settings() # ⬅️ ضروري نحفظو الاسم الجديد
	display_player_name() # ⬅️ تحديث الاسم في Home
	# 💡 الكود الجديد: طلب تحديث الـ HUD
	var hud_node = get_tree().root.get_node_or_null("res://scenes/UI/hud.tscn")
	if hud_node:
		hud_node.update_player_name() # ⬅️ المناداة على دالة التحديث في HUD.gd

func _on_timer_timeout() -> void:
	$AnimationPlayer.play("star")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "star":
		$Timer.start()
	# ✅ إذا كان عندك أنيميشن ديال 'setting_out' خصك هنا ترجع is_menu_busy لـ false

func _on_play_pressed() -> void:
	if not is_menu_busy:
		if has_save:
			is_menu_busy = true
			$warning.visible = true
			return
		else :
			var game_node = get_tree().root.get_node("Game")
		
			if GlobalSettings.has_saved_game():
				var dir = DirAccess.open("user://") # ⬅️ الوصول لمجلد المستخدم
				if dir:
					dir.remove("savegame.json")
	
			if game_node:
				# ✅ الآن يمكننا المناداة بأمان
				game_node.load_level1()
			else:
				print("ERROR: Could not find 'Game' node! Check Main Scene setting.")


func _on_continue_pressed() -> void:
	if not is_menu_busy:
		var game_node = get_tree().root.get_node("Game")
		if game_node:
			game_node.load_saved_game()

func _on_settings_pressed() -> void:
	if not is_menu_busy:
		$Settings.visible = true
		is_menu_busy = true # سدينا القائمة

func _on_about_pressed() -> void:
	if not is_menu_busy:
		$about.visible = true
		is_menu_busy = true

func _on_exit_pressed() -> void:
	if not is_menu_busy:
		$go_out.visible = true
		is_menu_busy = true

func _on_yes_pressed() -> void:
	get_tree().quit()

func _on_no_pressed() -> void:
	$go_out.visible = false
	is_menu_busy = false # حلينا القائمة


func _on_warning_yes_pressed() -> void:
	var game_node = get_tree().root.get_node("Game")
	
	if GlobalSettings.has_saved_game():
		var dir = DirAccess.open("user://") # ⬅️ الوصول لمجلد المستخدم
		if dir:
			dir.remove("savegame.json")
	
	if game_node:
		# ✅ الآن يمكننا المناداة بأمان
		game_node.load_level1()
	else:
		print("ERROR: Could not find 'Game' node! Check Main Scene setting.")


func _on_warning_no_pressed() -> void:
	$warning.visible = false
	is_menu_busy = false
