# Red.gd
extends Node

@onready var music_player = $AudioStreamPlayer2D # ⬅️ تأكد من الاسم

func _ready():
	# 1. يسجل نفسه في GlobalSettings
	GlobalSettings.register_red(self) 
	# 2. بدأ التشغيل 
	music_player.play() 
	# 3. تطبيق الإعدادات الأولية
	GlobalSettings.apply_audio_settings()
