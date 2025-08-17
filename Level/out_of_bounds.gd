class_name OutOfBoundsArea extends Area2D

# The level that the out of bounds area is in
@export var level : int = 1

## Connects the body_entered signal to the _kill_player subroutine
func _ready() -> void:
	body_entered.connect(_kill_player)


## Checks if the object that entered is the player; calls level manager
func _kill_player(p: Node2D) -> void:
	if p == PlayerManager.player:
		LevelManager.start_level(level)
