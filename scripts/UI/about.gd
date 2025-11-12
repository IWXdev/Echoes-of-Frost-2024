extends Control

func _on_exit_pressed() -> void:
	$"../AnimationPlayer".play("about_out")
	$"..".is_menu_busy = false

#link of my social acounte
func _on_steam_pressed() -> void:
	OS.shell_open("https://steamcommunity.com/profiles/76561199401815246/")

func _on_github_pressed() -> void:
	OS.shell_open("https://github.com/IWXdev")

func _on_instagram_pressed() -> void:
	OS.shell_open("https://www.instagram.com/ayoub__iwx")

func _on_epic_game_pressed() -> void:
	OS.shell_open("https://launcher.store.epicgames.com/u/a96a8a36bf0b4f4faf7ec03c3a086ce4")

func _on_itch_io_pressed() -> void:
	OS.shell_open("https://iwx-10.itch.io/")
