extends Node

@onready var player : CharacterBody2D = get_node("/root/Node2D/Player")

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
