class_name AttackBox extends Area2D

signal can_attack
signal cannot_attack

## Connects the body entered + exited signals to the necessary subroutines
func _ready() -> void:
	body_entered.connect(_attack_opportunity)
	body_exited.connect(_no_attack_opportunity)


## Runs when the attack range has been entered
func _attack_opportunity(p: Node2D) -> void:
	# Check what has entered the attack box. Only emit if player
	if p == PlayerManager.player:
		can_attack.emit()

## Runs when the attack range has been exited
func _no_attack_opportunity(p: Node2D) -> void:
	# Check what has exited the attack box. Only emit if player
	if p == PlayerManager.player:
		cannot_attack.emit()
