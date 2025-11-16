# MenuButton_Logic.gd (مربوط بـ MenuButton)
extends MenuButton

var is_paused = false

# 💡 النودات الأخرى هي جيران لـ MenuButton
# كنستعملو $Panel و $SettingsMenu مباشرة
# الصحيح هو:
@onready var main_panel = $"../Panel"  # إذا كانو مباشرة تحت HUD/Control
@onready var settings_menu = $"../SettingsMenu"
@onready var go_out_menu = $"../go_out"

# 💡 بما أن كل النودات كاينين مباشرة تحت Control (الأب ديال MenuButton)
# يمكننا استعمال المسار القصير $NodeName مباشرة إذا كنا داخل سكريبت الأب (HUD.gd)
# لكن بما أننا في MenuButton (الابن)، كنستعملو المسار النسبي:

@onready var hud_root = get_parent() # هذا هو Control

func _ready():
	# ... (ربط الـ Popup Signals) ...
	var popup = get_popup()
	if popup:
		popup.id_pressed.connect(_on_item_selected)

	# ... (باقي الدوال) ...

func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	
	main_panel.visible = is_paused
	
	if not is_paused:
		settings_menu.visible = false
		go_out_menu.visible = false

# ... (باقي الدوال ديال Exit, Setting...)


# ----------------------------------------------------
# 🔹 دالة MenuButton (ماذا يحدث عند الضغط على زر في القائمة)
# ----------------------------------------------------

func _on_item_selected(id: int):
	# ID: 0 -> Settings
	# ID: 1 -> Save
	# ID: 2 -> Resume
	# ID: 3 -> Exit
	
	match id:
		0: 
			Setting()
		1: 
			call_save_game()
		2: 
			toggle_pause()
		3: 
			ExitConfirmation()


func Setting():
	settings_menu.visible = true
	
func ExitConfirmation():
	go_out_menu.visible = true

func call_save_game():
	var game_node = get_tree().root.get_node("Game")
	if game_node:
		var player_node = game_node.get_node("samourai") # ⬅️ نود Player ديالك
		var current_path = game_node.current_level.get_child(0).scene_file_path # ⬅️ مسار المستوى الحالي
		
		GlobalSettings.save_game(player_node, current_path)
		print("Game saved!")

# ----------------------------------------------------
# 🔹 دوال أزرار قوائم الخروج و الإعدادات
# ----------------------------------------------------

# زر Yes في قائمة الخروج
func _on_yes_pressed() -> void:
	get_tree().quit()

# زر No في قائمة الخروج
func _on_no_pressed() -> void:
	go_out_menu.visible = false

# زر Resume المنفصل (إذا كان عندك زر في الـ Panel)
func _on_resume_button_pressed() -> void:
	toggle_pause()
