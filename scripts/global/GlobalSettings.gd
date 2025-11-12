# GlobalSettings.gd (يجب أن يكون Autoload)
extends Node

# ----------------------------------------------------
# 📌 المتغيرات (الحالة العامة)
# ----------------------------------------------------

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
var brightness_modulator: CanvasModulate = null # ⬅️ مرجع جديد

const RESOLUTIONS = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080)
]

# 📦 مسار الحفظ
const SAVE_PATH = "user://game_settings.cfg"


func _ready():
	load_settings() # ⬅️ تحميل الإعدادات عند بدء اللعبة
	
	call_deferred("find_brightness_modulator")

# ----------------------------------------------------
# 💾 دوال الحفظ والتحميل (Save/Load)
# ----------------------------------------------------

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if err == OK:
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

	# تطبيق الإعدادات المحملة
	apply_audio_settings()
	apply_graphics_settings()


func save_settings():
	var config = ConfigFile.new()
	
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
	
	config.save(SAVE_PATH)


# ----------------------------------------------------
# 🔊 دوال تطبيق الإعدادات (Apply Logic)
# ----------------------------------------------------

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


# ----------------------------------------------------
# 📞 دوال التعديل (Setters)
# ----------------------------------------------------

# -------------------
# 🔊 VOLUME SETTERS
# -------------------

func register_red(node: Node) -> void:
	# 💡 يتم تخزين المرجع لمشهد Red
	red_music_node = node
	
	# 💡 فور التسجيل، نطبق الإعدادات المحملة
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


# -------------------
# 🔇 MUTE SETTERS
# -------------------

func set_master_mute(value: bool) -> void:
	master_muted = value
	apply_audio_settings()

func set_music_mute(value: bool) -> void:
	music_muted = value
	apply_audio_settings()

func set_sfx_mute(value: bool) -> void:
	sfx_muted = value
	apply_audio_settings()


# -------------------
# 🖥️ GRAPHICS SETTERS
# -------------------

func find_brightness_modulator():
	# كنبحثو على النود اللي ضفناها في Game.tscn
	var game_node = get_tree().root.get_node_or_null("Game")
	if game_node:
		brightness_modulator = game_node.get_node_or_null("GlobalBrightnessModulator")
		print("HSlider work")
		if not brightness_modulator:
			print("ERROR: CanvasModulate node 'GlobalBrightnessModulator' not found in Game scene!")
	# إذا لقيناه، غادي يتسجل في brightness_modulator
	
func set_brightness(value: float) -> void:
	# هذا هو المتغير لي كيحافظ على القيمة
	brightness_level = value 
	
	# 💡 نادِ على الدالة لي كطبق الـ Graphics (لي فيها set_global_brightness)
	apply_graphics_settings()

func toggle_vsync(state: bool) -> void:
	vsync_enabled = state
	apply_graphics_settings() # تطبيق التغيير مباشرة

func set_resolution_index(index: int) -> void:
#	# 💡 هذا Setter ما كيحتاجش متغير جديد حيت كنخدمو بـ current_resolution_index
	current_resolution_index = index
	apply_graphics_settings() # تطبيق التغيير مباشرة
