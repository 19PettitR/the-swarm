class_name HitBox extends Area2D

# Signals when the player enters the hitbox so the enemy can check for attacks
signal player_in_hitbox
# Signals when the player has left the hitbox so the enemy stops checking for attacks
signal player_not_in_hitbox


## Connects the body entered signal to attack
func _ready() -> void:
	area_entered.connect(_attacked)


## Runs when the hit box has been entered by an area
func _attacked(p: Node2D) -> void:
	if p == PlayerManager.attack_range:
		player_in_hitbox.emit()


## Runs when the hit box has been exited by an area
func _not_attacked(p: Node2D) -> void:
	if p == PlayerManager.attack_range:
		player_not_in_hitbox.emit()
