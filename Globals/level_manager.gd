extends Node


## Handles the when the player exits the level
func end_level(l:int) -> void:
	print("player has exited level ", l)


## Handles starting a new level (will have paramter); handles player death (no parameter)
func start_level(l:int) -> void:
	print("player has died on level ", l)
