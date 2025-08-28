extends Node

@onready var player : CharacterBody2D = get_node("/root/Node2D/Player")
# Needed so the enemies can detect when they are being attacked
@onready var attack_range : Area2D = get_node("/root/Node2D/Player/Attack Range")
# Needed so the enemies can check when they have damaged the player
@onready var hit_box : Area2D = get_node("/root/Node2D/Player/Hit Box")
# Needed so that the camera boundaries can be set
@onready var camera : Camera2D = get_node("/root/Node2D/Player/Camera2D")


func _ready() -> void:
	LevelManager.level_start.connect(empty_inventory)
	


## Spawns the player in when starting or restarting a level
func spawn(pos:Vector2) -> void:
	# Position the player at the start of the level
	player.global_position = pos
	# Set the player's velocities (so they don't move fast on spawn)
	player.velocity = Vector2(0,0)
	# Set the player health
	player.health = player.max_health * 0.8
	# Set the player's attack_strength (delay for game_load subroutine to finish)
	await get_tree().process_frame
	player.attack_strength = player.begin_attack_strength
	
	# Change the left and right limits of the camera based on the level
	if LevelManager.current_level == 1:
		camera.limit_left = 0
		camera.limit_right = 4608
	elif LevelManager.current_level == 2:
		camera.limit_left = 4672
		camera.limit_right = 9280
	else:
		camera.limit_left = 9344
		camera.limit_right = 13952
	
	print("health on spawn: ", player.health, "   maximum health: ", player.max_health)
	print("attack strength: ", player.attack_strength, "   begin attack strength: ", player.begin_attack_strength)
	print("inventory: ", player.inventory)

## Updates the player's climbing variables. Last 4 parameters are optional; they have default variables
func update_climb(can_climb:bool, side:String="", pos:float=0, c_max:float=0, c_min:float=0 ) -> void:
	# If the boolean is true, then the player is entering a climbing area
	if can_climb:
		player.in_climbing_range = true
		player.climb_side = side.to_lower()
		player.climb_position = pos
		player.climb_maximum = c_max
		player.climb_minimum = c_min
	else:
		player.in_climbing_range = false


## Handles player taking damage
func player_health(s:int) -> void:
	# Player should die if their health goes below 0
	if player.health + s <= 0:
		LevelManager.start_level(LevelManager.current_level)
	# Player's health should be set to maximum if it reaches above its maximum
	elif player.health + s >= player.max_health:
		player.health = player.max_health
	else:
		player.health += s
	print(player.health)


## Adds items to the player's inventory
func item_add(id:String, strength:int, heal:int) -> void:
	# Add the item to the inventory
	player.inventory.append(id)
	# Update the necessary player variables
	player.attack_strength += strength
	player_health(heal)
	print(player.inventory)
	print(player.attack_strength)


## Empties the player's inventory on spawn/respawn
func empty_inventory() -> void:
	player.inventory.clear()
