extends Control

# ✅ متغير محلي لتفادي الضغطات المتعددة
var is_menu_busy: bool = false

func _ready() -> void:
	# 💡 تأكد أن هذا المشهد (Home) هو أول واحد كيتحمل عبر Game.gd
	$AnimationPlayer.play("star")

func _on_timer_timeout() -> void:
	$AnimationPlayer.play("star")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "star":
		$Timer.start()
	# ✅ إذا كان عندك أنيميشن ديال 'setting_out' خصك هنا ترجع is_menu_busy لـ false

func _on_play_pressed() -> void:
	var game_node = get_tree().root.get_node("Game")
	
	if game_node:
		# ✅ الآن يمكننا المناداة بأمان
		game_node.load_level1()
		print("play button work")
	else:
		# ⚠️ رسالة تحذيرية في حال وقوع الخطأ مرة أخرى
		print("ERROR: Could not find 'Game' node! Check Main Scene setting.")

func _on_settings_pressed() -> void:
	if not is_menu_busy:
		$AnimationPlayer.play("setting_in")
		is_menu_busy = true # سدينا القائمة

func _on_about_pressed() -> void:
	if not is_menu_busy:
		$AnimationPlayer.play("about_in")
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
