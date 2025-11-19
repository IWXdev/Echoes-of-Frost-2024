extends MenuButton

var is_paused = false

@onready var main_panel = $"../Panel" 
@onready var settings_menu = $"../SettingsMenu"
@onready var go_out_menu = $"../go_out"

@onready var hud_root = get_parent()

func _ready():
	
	var popup = get_popup()
	if popup:
		popup.id_pressed.connect(_on_item_selected)


func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	
	main_panel.visible = is_paused
	
	if not is_paused:
		settings_menu.visible = false
		go_out_menu.visible = false



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
		var player_node = game_node.get_node("samourai")
		var current_path = game_node.current_level.get_child(0).scene_file_path
		
		GlobalSettings.save_game(player_node, current_path)
		$"..".animate_center_message("Game saved!")



# Exit Yes
func _on_yes_pressed() -> void:
	get_tree().quit()

# Exit No
func _on_no_pressed() -> void:
	go_out_menu.visible = false

# Resume button
func _on_resume_button_pressed() -> void:
	toggle_pause()
