# LevelUpMenu.gd
extends Control

# 🔗 Array buttons
@onready var upgrade_buttons = [$background/Panel/HBoxContainer/UpgradeButton1, $background/Panel/HBoxContainer/UpgradeButton2, $background/Panel/HBoxContainer/UpgradeButton3]
@onready var description_label = $background/Panel/desc
@onready var skill_points_label = $background/Panel/skill_points


# all upgrades
const ALL_SKILLS = [
	{"key": "MAX_HP", "desc": "Max Health +5 hp", "type": "Health", "icon_path": "res://Asset/icon/LINK/icons8-health-100.png"},
	{"key": "MAX_STAMINA", "desc": "stamina +5 ", "type": "Stamina", "icon_path": "res://Asset/icon/LINK/icons8-power-100.png"},
	{"key": "ATTACK_DMG", "desc": "damage +5", "type": "Damage", "icon_path": "res://Asset/icon/LINK/icons8-sword-100.png"},
	{"key": "CRIT_CHANCE", "desc": "critical attack  +5% ", "type": "Damage_Crit", "icon_path": "res://Asset/icon/LINK/icons8-sword-100 (1).png"},
	{"key": "SPEED", "desc": "speed +3", "type": "Speed", "icon_path": "res://Asset/icon/LINK/icons8-exercise-100.png"},
	{"key": "STAMINA_RECO", "desc": "stamina recovery +5%", "type": "Stamina_Reco", "icon_path": "res://Asset/icon/LINK/icons8-pause-100.png"}
	# {"key": "LIFESTEAL", "desc": "مص الحياة: +3% فرصة لشفاء الذات", "type": "Utility"},
]

func _process(_delta: float) -> void:
	skill_points_label.text = "Skill Points  : " + str(GlobalSettings.skill_points)

# -----------------------------------
# open menu func
# -----------------------------------
func open_menu():
	if GlobalSettings.skill_points < 1:
		return
	update_skill_points_display()
	self.show()
	get_tree().paused = true # pause the game
	description_label.text = "Choose the development that suits you"
	description_label.modulate.a = 1.0
	generate_skill_choices()


# -----------------------------------
# func select 3 devs
# -----------------------------------
func generate_skill_choices():
	# 1. desibel old buttons ()
	for btn in upgrade_buttons:
		if btn.is_connected("pressed", Callable(self, "apply_upgrade")):
			btn.disconnect("pressed", Callable(self, "apply_upgrade"))
			
		# DISCONNECT 'mouse_entered' (NEW: to fix the warning)
		if btn.is_connected("mouse_entered", Callable(self, "_on_upgrade_button_mouse_entered")):
			# Note: Use the base callable, not the bound one, for disconnect
			btn.disconnect("mouse_entered", Callable(self, "_on_upgrade_button_mouse_entered"))
	# 2. select 3 devs 
	var mutable_skills = ALL_SKILLS.duplicate()
	
	mutable_skills.shuffle()
	var current_choices = mutable_skills.slice(0, 3)

	# 3. buttons
	for i in range(upgrade_buttons.size()):
		var skill_data = current_choices[i]
		var btn = upgrade_buttons[i]
		
		#btn.text = skill_data.desc
		var icon_texture = load(skill_data.icon_path)
		
		#Icons
		if icon_texture is Texture2D:
			btn.icon = icon_texture
		
		# connect the buttons
		btn.connect("mouse_entered", Callable(self, "_on_upgrade_button_mouse_entered").bind(skill_data.desc))
		btn.connect("pressed", Callable(self, "apply_upgrade").bind(skill_data.key), CONNECT_ONE_SHOT)
		# CONNECT_ONE_SHOT button work 1 time
		
# -----------------------------------
# app the devs
# -----------------------------------
func apply_upgrade(skill_key: String):
	# 1.check if has point skill
	if GlobalSettings.skill_points <= 0:
		return
	
	
	# 2.app to GlobalSettings
	match skill_key:
		"MAX_HP":
			GlobalSettings.player_max_health += 10
		"MAX_STAMINA":
			GlobalSettings.player_max_stamina += 5.0
		"ATTACK_DMG":
			GlobalSettings.player_damage_base += 5.0
		"CRIT_CHANCE":
			GlobalSettings.player_crit_chance += 0.05
		"SPEED":
			GlobalSettings.player_speed += 5
		"STAMINA_RECO":
			GlobalSettings.player_stamina_recovery += 0.05
	# 3.consome the point
	GlobalSettings.skill_points -= 1
	update_skill_points_display()
	# 4.close the menu and return to game 
	close_menu()

func update_skill_points_display():
	skill_points_label.text = "Skill Points : " + str(GlobalSettings.skill_points)

# close func
func close_menu():
	self.hide()
	get_tree().paused = false 

# -----------------------------------
# Desc Func
# -----------------------------------

# 1. mouse eneterd the button
func _on_upgrade_button_mouse_entered(description: String):
	description_label.text = description
	description_label.modulate.a = 1.0 

# 2. mouse exited the button
func _on_upgrade_button_mouse_exited():
	# return to the normal 
	description_label.text = "Choose the development that suits you"
