class_name Item extends Area2D

# Reference to the player so it can be checked whether they touched the item
@onready var player = PlayerManager.player

# Variables about item
@export var item_id : String = ""
@export var item_strength : int = 0
@export var item_heal : int = 0

# Stores whether the item has been collected or not
var collected : bool = false
# Stores original position of the item (used when respawning)
var my_position : Vector2


## Connects signals to subroutines, sets my_position
func _ready() -> void:
	body_entered.connect(_collection)
	LevelManager.level_start.connect(_respawn)
	# Store the position of the itme when starting
	my_position = global_position
	_check_if_collected()


## Check the save file for if the item has been collected; set the collected variable
func _check_if_collected() -> void:
	
	# If the item is strengthening item, check corresponding index of the level manager's item_status
	if item_id.begins_with("ST"):
		# Item collected if 1
		if LevelManager.item_status[int(item_id[2]+item_id[3])] == 1:
			# Set the collected variable and move out of the player's sight
			collected = true
			global_position = LevelManager.disappear_position
	
	# If the item is a collectible, check the corresponding index of the level manager's item_status
	elif item_id.begins_with("CL"):
		# Item collected if 1
		if LevelManager.item_status[int(item_id[2]+item_id[3])+4] == 1:
			# Set the collected variable and move out of the player's sight
			collected = true
			global_position = LevelManager.disappear_position


## Responsible for handling the item's collection
func _collection(p:Node2D) -> void:
	if p == player:
		# Add the item to the player's inventory and update their variables
		PlayerManager.item_add(item_id, item_strength, item_heal)
		# Change the position of the item so it is out of the player's sight
		global_position = LevelManager.disappear_position


## Respawn the item when level starts/restarts
func _respawn() -> void:
	_check_if_collected()
	# Items should only respawn if not collected in a previous save/level
	if not collected:
		global_position = my_position
