class_name Door extends Area2D

# Reference to the player to check if the player touched the door
@onready var player = PlayerManager.player
# Reference to the key that unlocks the door
@export var unlock_key : String
# Used in later milestones
var my_position


## Connects the body_entered signal to the _open subroutine
func _ready() -> void:
	body_entered.connect(_open)


## Responsible for opening the door when the player touches the door
func _open(p:Node2D) -> void:
	if p == player:
		for id in range(len(player.inventory)):
			if player.inventory[id] == unlock_key:
				_unlock()
	else:
		if str(p.name).begins_with("Enemy"):
			p.turn_around()
			


## Once the door has been unlocked, change position so it cannot be seen
func _unlock() -> void:
	global_position = LevelManager.disappear_position
