class_name ExitArea extends Area2D

# The level that the player is exiting
@export var exit_level : int = 1

## Connects the body_entered signal to the _next_level subroutine
func _ready() -> void:
	body_entered.connect(_end_level)


## Checks if the object that entered is the player; calls level manager
func _end_level(p: Node2D) -> void:
	if p == PlayerManager.player:
		LevelManager.end_level(exit_level)
