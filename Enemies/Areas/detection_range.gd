class_name DetectionRange extends Area2D

signal seen
signal not_seen

## Connects the body entered + exited signals to the necessary subroutines
func _ready() -> void:
	body_entered.connect(_detected)
	body_exited.connect(_undetected)


## Runs when the detection range has been entered
func _detected(p: Node2D) -> void:
	# Check what has entered the detection range. Only emit if player
	if p == PlayerManager.player:
		seen.emit()

## Runs when the detection range has been exited
func _undetected(p: Node2D) -> void:
	# Check what has exited the detection range. Only emit if player
	if p == PlayerManager.player:
		not_seen.emit()
