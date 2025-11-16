# GlobalSettings.gd (Autoload)
extends Node

signal level_up(new_level)
signal xp_spawn_requested(amount: int, position: Vector2)
# The varibels

# XP System
var player_level: int = 1
var player_xp: int = 0
var xp_to_next_level: int = 100

# Player Info
var player_name: String = ""

# Audio
var master_volume: float = 1.0 
var music_volume: float = 1.0  
var sfx_volume: float = 1.0 
var master_muted: bool = false
var music_muted: bool = false
var sfx_muted: bool = false

var red_music_node: Node = null
# Graphics
var vsync_enabled: bool = true 
var current_resolution_index: int = 0
var brightness_level: float = 1.0
var brightness_modulator: CanvasModulate = null

const RESOLUTIONS = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080)
]

# Save Paths
const SETTING_SAVE_PATH = "user://game_settings.json"
const GAME_SAVE_PATH = "user://savegame.json"


func _ready():
	load_settings() # load setting save if start the game
	
	call_deferred("find_brightness_modulator")

# functions (Save/Load) Setting
#Load setting data
func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTING_SAVE_PATH)
	
	if err == OK:
		player_name = config.get_value("player_info", "name", "player")
		# Audio
		master_volume = config.get_value("audio", "master_volume", 1.0)
		music_volume = config.get_value("audio", "music_volume", 1.0)
		sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
		master_muted = config.get_value("audio", "master_muted", false)
		music_muted = config.get_value("audio", "music_muted", false)
		sfx_muted = config.get_value("audio", "sfx_muted", false)
		
		# Graphics
		brightness_level = config.get_value("graphics", "brightness_level", 1.0)
		vsync_enabled = config.get_value("graphics", "vsync", true)
		current_resolution_index = config.get_value("graphics", "resolution_index", 0)

	# applic the setting
	apply_audio_settings()
	apply_graphics_settings()

#Save setting data
func save_settings():
	var config = ConfigFile.new()
	config.set_value("player_info", "name", player_name)
	# Audio
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "master_muted", master_muted)
	config.set_value("audio", "music_muted", music_muted)
	config.set_value("audio", "sfx_muted", sfx_muted)

	# Graphics
	config.set_value("graphics", "brightness_level", brightness_level)
	config.set_value("graphics", "vsync", vsync_enabled)
	config.set_value("graphics", "resolution_index", current_resolution_index)
	
	config.save(SETTING_SAVE_PATH)


# Functions save game (JSON)

# save game
func save_game(player_node: Node, level_scene_path: String):
	# Dictionary
	var save_data = {
		"player": {
			"health": player_node.health,
			"stamina": player_node.stamina,
			"pos_x": player_node.global_position.x,
			"pos_y": player_node.global_position.y
		},
		"game": {
			"current_level": level_scene_path
		},
		"player_info" : {
			"name" : player_name,
			"level" : player_level,
			"xp": player_xp,
			"xp_to_next": xp_to_next_level
		}
	}
	
	# trans Dictionary to text JSON
	var json_string = JSON.stringify(save_data, "\t", true)
	
	# write text in Dictionary
	var file = FileAccess.open(GAME_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		print("Game saved successfully to JSON!")
	else:
		print("Error saving game: Could not open file.")


func load_game() -> Dictionary:
	var file = FileAccess.open(GAME_SAVE_PATH, FileAccess.READ)
	
	if file:
		# read the text from the file
		var json_string = file.get_as_text()
		
		# 2. trans JSON to Dictionary
		var parse_result = JSON.parse_string(json_string)
		
		if parse_result is Dictionary:
			var config = parse_result
			# load player name to ginral var
			if config.has("player_info"):
				var info = config.player_info
				player_name = info.name
				player_level = info.level
				player_xp = info.xp
				xp_to_next_level = info.xp_to_next
			print("Game data loaded successfully from JSON.")
			return config
		else:
			print("Error parsing JSON data.")
			return {}
	else:
		print("No saved game found.")
		return {} # return the Dictionary empty


# Check save data File 
func has_saved_game() -> bool:
	# Check data File
	return FileAccess.file_exists(GAME_SAVE_PATH)


# 🔊 func app (Apply Logic)
func apply_audio_settings():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume))
	
	# Mute Logic
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), master_muted)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), music_muted)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), sfx_muted)

func apply_graphics_settings():
	# ... (Resolution & VSync Logic) ...

	# ----------------------------------
	# Brightness Logic (تصحيح)
	# ----------------------------------
	if brightness_modulator:
		# ✅ هذا هو الكود الصحيح: نطبق Modulate مباشرة على CanvasModulate
		var color_value = clamp(brightness_level, 0.0, 1.0)
		brightness_modulator.color = Color(color_value, color_value, color_value, 1.0)
	else:
		# ⚠️ إذا فشل العثور عليه، هذا يعني أننا لم نقم بعد بـ find_brightness_modulator()
		# أو أن النود غير موجودة في المشهد.
		print("WARNING: CanvasModulate not yet found/registered. Skipping brightness application.")
	
	# Resolution
	var res = RESOLUTIONS[current_resolution_index]
	DisplayServer.window_set_size(res)
	
	# VSync
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED
	)


func gain_xp(amount: int, player: Node):
	player_xp += amount
	print("XP Gained: ", amount)
	xp_spawn_requested.emit(amount, player.get_head_position())
	# check if player arrived at next level
	check_level_up()

func check_level_up():
	if player_xp >= xp_to_next_level:
		perform_level_up()
		check_level_up()

func perform_level_up():
	# 1. إزالة XP الزائد من XP الحالي
	player_xp -= xp_to_next_level
	
	# 2. زيادة المستوى
	player_level += 1
	
	# 3. تحديد XP المطلوب للمستوى التالي
	#  (نظام بسيط: نحتاج 20 نقطة زيادة لكل مستوى)
	xp_to_next_level = int(xp_to_next_level * 1.5) # يزيد بـ 50%
	level_up.emit(player_level) 
	print("LEVEL UP! New Level: ", player_level)
	#  هنا يمكن إضافة إشارة (Signal) لتحديث الـ HUD أو تشغيل مؤثرات صوتية
	# emit_signal("level_up", player_level)

# FUNCTION (Setters)

# VOLUME SETTERS
func register_red(node: Node) -> void:
	# save Red scene
	red_music_node = node
	# apply setters
	apply_audio_settings()
func set_master_volume(value: float) -> void:
	master_volume = value
	apply_audio_settings()
func set_music_volume(value: float) -> void:
	music_volume = value
	apply_audio_settings()
func set_sfx_volume(value: float) -> void:
	sfx_volume = value
	apply_audio_settings()


# MUTE SETTERS
func set_master_mute(value: bool) -> void:
	master_muted = value
	apply_audio_settings()
func set_music_mute(value: bool) -> void:
	music_muted = value
	apply_audio_settings()
func set_sfx_mute(value: bool) -> void:
	sfx_muted = value
	apply_audio_settings()


# 🖥️ GRAPHICS SETTERS
func find_brightness_modulator():
	# search node Game.tscn
	var game_node = get_tree().root.get_node_or_null("Game")
	if game_node:
		brightness_modulator = game_node.get_node_or_null("GlobalBrightnessModulator")
		print("HSlider work")
		if not brightness_modulator:
			print("ERROR: CanvasModulate node 'GlobalBrightnessModulator' not found in Game scene!")
func set_brightness(value: float) -> void:
	brightness_level = value 
	
	# Graphics call (set_global_brightness)
	apply_graphics_settings()
func toggle_vsync(state: bool) -> void:
	vsync_enabled = state
	apply_graphics_settings() #app change
func set_resolution_index(index: int) -> void:
# current_resolution_index
	current_resolution_index = index
	apply_graphics_settings()
