# Red.gd
extends Node

@onready var music_player = $AudioStreamPlayer2D 

func _ready():
	# 1.save at GlobalSettings
	GlobalSettings.register_red(self) 
	# 2. play 
	music_player.play() 
	# 3. app the basec setting
	GlobalSettings.apply_audio_settings()
