extends Control

var is_menu_busy: bool = false
@onready var continue_button = $VBoxContainer/Continue
@onready var player_name_label = $PlayerNameLabel
@onready var load_status_label = $LoadStatusLabel
var has_save = GlobalSettings.has_saved_game()

func _ready() -> void:
	$AnimationPlayer.play("star")
	if has_save:
		continue_button.show()
		load_status_label.text = "  Data uploaded successfully !  " 
		animate_load_status(load_status_label) #
	else:
		load_status_label.hide()
		continue_button.hide()
	display_player_name()
	if not has_save and GlobalSettings.player_name == "":
		call_deferred("show_name_popup") #awite show

func animate_load_status(label: Label):
	# 1. show the label
	label.modulate.a = 1.0 
	label.position.y -= 0
	
	var tween = create_tween()
	
	# 2. down to teh position
	tween.tween_property(label, "position", label.position + Vector2(0, 35), 1.5) \
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		
	# 3. wite 1.5s
	tween.tween_interval(1.5)
	
	# 4.hide step by step (Fade out) and up
	tween.tween_property(label, "modulate:a", 0.0, 0.7)
	tween.tween_property(label, "position:y", label.position.y - 25, 1)
	
	# 5. clean the Label aftar finish
	await tween.finished
	label.hide() # hide Label

func display_player_name():
	# load the save name
	player_name_label.text = GlobalSettings.player_name

func show_name_popup():
	# load scene window
	var popup_scene = load("res://scenes/UI/player_name_popup.tscn")
	var popup = popup_scene.instantiate()
	add_child(popup)
	
	#connect the signal
	popup.name_entered.connect(Callable(self, "_on_name_entered"))


func _on_name_entered(player_name_input):
	# if player enetr name
	GlobalSettings.player_name = player_name_input
	GlobalSettings.save_settings() # save new name
	display_player_name() # update name ==> home
	# update name ==> HUD
	var hud_node = get_tree().root.get_node_or_null("res://scenes/UI/hud.tscn")
	if hud_node:
		hud_node.update_player_name() # call the fund update HUD.gd

func _on_timer_timeout() -> void:
	$AnimationPlayer.play("star")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "star":
		$Timer.start()

func _on_play_pressed() -> void:
	if not is_menu_busy:
		if has_save:
			is_menu_busy = true
			$warning.visible = true
			return
		else :
			var game_node = get_tree().root.get_node("Game")
		
			if GlobalSettings.has_saved_game():
				var dir = DirAccess.open("user://") # open user folder
				if dir:
					dir.remove("savegame.json")
	
			if game_node:
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
		is_menu_busy = true

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
	is_menu_busy = false


func _on_warning_yes_pressed() -> void:
	var game_node = get_tree().root.get_node("Game")
	
	if GlobalSettings.has_saved_game():
		var dir = DirAccess.open("user://") # open user folder
		if dir:
			# delet the save data
			dir.remove("savegame.json")
	
	if game_node:
		game_node.load_level1()
	else:
		print("ERROR: Could not find 'Game' node! Check Main Scene setting.")


func _on_warning_no_pressed() -> void:
	$warning.visible = false
	is_menu_busy = false
