class_name HitBox extends Area2D

signal take_damage

## Connects the body entered signal to attack
func _ready() -> void:
	body_entered.connect(_attacked)


## Runs when the hit box has been entered
func _attacked(_p: Node2D) -> void:
	take_damage.emit()
