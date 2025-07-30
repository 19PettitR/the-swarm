extends Node

@onready var player : CharacterBody2D = get_node("/root/Node2D/Player")
# Needed so the enemies can detect when they are being attacked
@onready var attack_range : Area2D = get_node("/root/Node2D/Player/Attack Range")
# Needed so the enemies can check when they have damaged the player
@onready var hit_box : Area2D = get_node("/root/Node2D/Player/Hit Box")

## Before anything else, wait for the first process frame since globals load first
func _ready() -> void:
	await get_tree().process_frame


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
		_player_die()
	# Player's health should be set to maximum if it reaches above its maximum
	elif player.health + s >= player.max_health:
		player.health = player.max_health
	else:
		player.health += s
	print(player.health)


## Handles player death
func _player_die() -> void:
	print("player has died")


## Adds items to the player's inventory
func item_add(id:String, strength:int, heal:int) -> void:
	# Add the item to the inventory
	player.inventory.append(id)
	# Update the necessary player variables
	player.attack_strength += strength
	player_health(heal)
	print(player.inventory)
	print(player.attack_strength)
