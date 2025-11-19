extends Node

@onready var current_level = $currentLevel
@onready var loading_screen = $Loading
@onready var player = $samourai
@onready var hud_node = $HUD
@onready var splash_screen = $splash

const FLOATING_XP_SCENE = preload("res://scenes/UI/floating_xp.tscn")
var saved_game_data: Dictionary = {}


func _ready():
	if player:
		player.hide()
		player.player_camera.enabled = false
	if hud_node:
		hud_node.hide()
	if loading_screen and is_instance_valid(loading_screen):
		if not loading_screen.scene_loaded.is_connected(_on_scene_loaded):
			loading_screen.scene_loaded.connect(_on_scene_loaded)
		
		if splash_screen and is_instance_valid(splash_screen):
			splash_screen.splash_finished.connect(_on_splash_finished)
		
		
	if player and not player.died.is_connected(Callable(self, "_on_player_died")):
		player.died.connect(Callable(self, "_on_player_died"))
	if not GlobalSettings.xp_spawn_requested.is_connected(Callable(self, "_on_xp_spawn_requested")):
		GlobalSettings.xp_spawn_requested.connect(Callable(self, "_on_xp_spawn_requested"))

func _on_xp_spawn_requested(amount: int, position: Vector2):
	# 1. copy the Label
	var xp_label = FLOATING_XP_SCENE.instantiate()
	
	# 2. write the text
	xp_label.text = "+" + str(amount) + " XP"
	# (Global Position - 50px)
	xp_label.global_position = position
	
	current_level.add_child(xp_label)

func _on_player_died():
	await get_tree().create_timer(1.0).timeout    
	#(Respawn)
	load_level1()

func clear_level():
	# deferred
	for child in current_level.get_children():
		child.call_deferred("queue_free")


func load_home():
	if player:
		player.hide()
		player.player_camera.enabled = false
	if hud_node:
		hud_node.hide()
	if loading_screen and is_instance_valid(loading_screen):
		loading_screen.start_loading("res://scenes/UI/home.tscn")
		print("tama ta7mil home bi njah")



func load_level1():
	if player:
		player.show()
	if loading_screen and is_instance_valid(loading_screen):
		print("scene is laoding")
		loading_screen.start_loading("res://scenes/levels/level.tscn")
	else:
		print("scene not laoding")

func load_saved_game():
	saved_game_data = GlobalSettings.load_game() # save data her
	var level_path = saved_game_data.game.current_level if saved_game_data.has("game") else "res://scenes/UI/home.tscn"
	if player: player.show()
	
	if loading_screen and is_instance_valid(loading_screen):
		loading_screen.start_loading(level_path) 
	else:
		print("CRITICAL ERROR: Loading Screen not ready for saved game load.")

func _on_splash_finished():
	load_home()
	print("SplashScreen finished, starting Home scene load.")

func _on_scene_loaded(scene: PackedScene):
	clear_level()
	var new_scene = scene.instantiate()
	current_level.add_child(new_scene)
	var is_load_game = not saved_game_data.is_empty()

	# 1 RESET PLAYER STATE
	# check Player not dead
	if player:
		player.is_dead = false
		player.set_process_input(true)
		player.set_physics_process(true)

	# 2 LOAD GAME LOGIC ()
	if is_load_game:
		# applic (health, stamina, position)
		var data = saved_game_data.player
		player.health = data.health
		player.stamina = data.stamina
		player.global_position = Vector2(data.pos_x, data.pos_y)
		saved_game_data = {}

	# 3 NEW GAME/RESPAWN LOGIC (Load Game)
	else: # if not has save game (New Game أو Respawn)
		# Health Max Health (New Game/Respawn)
		player.health = GlobalSettings.player_max_health
		player.stamina = GlobalSettings.player_max_stamina
		
		if player.visible: #Home
			set_player_spawn(new_scene) 

	# 4 FINAL SETUP
	if player.visible:
		if player.player_camera:
			player.player_camera.enabled = true
		if hud_node:
			hud_node.show()

	loading_screen.hide()
	await get_tree().process_frame


func set_player_spawn(level_scene: Node) -> void:
	# Marker2D = SpawnPoint in Level.tscn
	var spawn_point = level_scene.get_node_or_null("SpawnPoint") 
	
	if spawn_point:
		#Spawn Point position
		player.global_position = spawn_point.global_position
	else:
		print("SpawnPoint not found")
