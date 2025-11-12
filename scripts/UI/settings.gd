extends Control

# 🔗 تعريف العناصر (بناءً على البنية ديالك: VB/TabC/...)
# MASTER
@onready var master_slider = $setting/VB/TabC/Audio/Master/name/HSlider
@onready var master_mute_box = $setting/VB/TabC/Audio/Master/name/CheckBox

# MUSIC
@onready var music_slider = $setting/VB/TabC/Audio/music/name/HSlider
@onready var music_mute_box = $setting/VB/TabC/Audio/music/name/CheckBox

# SFX
@onready var sfx_slider = $setting/VB/TabC/Audio/SFX/name/HSlider
@onready var sfx_mute_box = $setting/VB/TabC/Audio/SFX/name/CheckBox

# Graphics
#@onready var fullscreen_toggle = $VB/TabC/Graphics/FullScreenCheckBox
@onready var vsync_toggle = $setting/VB/TabC/Graphics/VBoxContainer2/Label/CheckBox
@onready var resolution_option = $setting/VB/TabC/Graphics/VBoxContainer3/Label/OptionButton
@onready var brightness_slider = $setting/VB/TabC/Graphics/VBoxContainer/Label/HSlider


func _ready():
	# 💡 يتم تحميل وعرض القيم الحالية عند الفتح
	
	# Audio Init
	master_slider.value = GlobalSettings.master_volume
	master_mute_box.button_pressed = GlobalSettings.master_muted
	music_slider.value = GlobalSettings.music_volume
	music_mute_box.button_pressed = GlobalSettings.music_muted
	sfx_slider.value = GlobalSettings.sfx_volume
	sfx_mute_box.button_pressed = GlobalSettings.sfx_muted
	
	# Graphics Init
	brightness_slider.value = GlobalSettings.brightness_level
	vsync_toggle.button_pressed = GlobalSettings.vsync_enabled
	resolution_option.select(GlobalSettings.current_resolution_index)

	init_settings_values()

# ----------------------------------------------------
# 🔊 دوال التحكم في الصوت (يجب ربط HSlider/CheckBox بـ Signals)
# ----------------------------------------------------

# Master Volume / Mute
func _on_master_h_slider_value_changed(value: float) -> void:
	GlobalSettings.set_master_volume(value)
func _on_master_check_box_toggled(toggled_on: bool) -> void:
	GlobalSettings.set_master_mute(toggled_on)
	master_slider.editable = not toggled_on

# Music Volume / Mute
func _on_music_h_slider_value_changed(value: float) -> void:
	GlobalSettings.set_music_volume(value)
func _on_music_check_box_toggled(toggled_on: bool) -> void:
	GlobalSettings.set_music_mute(toggled_on)
	music_slider.editable = not toggled_on

# SFX Volume / Mute
func _on_sfx_h_slider_value_changed(value: float) -> void:
	GlobalSettings.set_sfx_volume(value)
func _on_sfx_check_box_toggled(toggled_on: bool) -> void:
	GlobalSettings.set_sfx_mute(toggled_on)
	sfx_slider.editable = not toggled_on


# ----------------------------------------------------
# 🖥️ دوال التحكم في الجرافيكس
# ----------------------------------------------------

func _on_brightness_slider_value_changed(value: float) -> void:
	GlobalSettings.set_brightness(value)

func _on_vsync_check_box_toggled(toggled_on: bool) -> void:
	GlobalSettings.toggle_vsync(toggled_on)

func _on_resolution_option_button_item_selected(index: int) -> void:
	GlobalSettings.current_resolution_index = index
	GlobalSettings.apply_graphics_settings()


func init_settings_values():
	# 💡 يُنادى هذا عند فتح القائمة أو في _ready()
	# 1. تحميل قيم الصوت
	master_slider.value = GlobalSettings.master_volume
	master_mute_box.button_pressed = GlobalSettings.master_muted
	# ... (باقي قيم Music و SFX)
	
	# 2. تحميل قيم الجرافيكس
	resolution_option.select(GlobalSettings.current_resolution_index)
	vsync_toggle.button_pressed = GlobalSettings.vsync_enabled

# ----------------------------------------------------
# 💾 دوال الحفظ والخروج
# ----------------------------------------------------


func _on_back_home_pressed() -> void:
	$"../AnimationPlayer".play("setting_out")
	$"..".is_menu_busy = false


func _on_apply_home_pressed() -> void:
	# 💡 حفظ كل التغييرات بشكل نهائي
	GlobalSettings.save_settings()
	$"../AnimationPlayer".play("setting_out")
	$"..".is_menu_busy = false
	print("Settings Applied and Saved!")


func _on_apply_level_pressed() -> void:
	$".".visible = false
	GlobalSettings.save_settings()


func _on_back_level_pressed() -> void:
	$".".visible = false
