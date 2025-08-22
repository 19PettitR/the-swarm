class_name Item extends Area2D

# Reference to the player so it can be checked whether they touched the item
@onready var player = PlayerManager.player

# Variables about item
@export var item_id : String = "1"
@export var item_strength : int = 2
@export var item_heal : int = 3

# Used in later milestones
var collected : bool = false
var my_position : Vector2


## Connects the body_entered signal to the _collection subroutine, sets the collected variable
func _ready() -> void:
	body_entered.connect(_collection)
	
	# If the item is a strengthening item, check the corresponding index of the level manager's item_status
	if item_id.begins_with("ST"):
		# Item collected if 1
		if LevelManager.item_status[int(item_id[2]+item_id[3])] == 1:
			# Set the collected variable and move out of the player's sight
			collected = true
			global_position = LevelManager.disappear_position
	# If the item is a collectible, check the corresponding index of the level amanger's item_status
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
