class_name DetectionRange extends Area2D

signal seen
signal not_seen

## Connects the body entered + exited signals to the necessary subroutines
func _ready() -> void:
	body_entered.connect(_detected)
	body_exited.connect(_undetected)


## Runs when the detection range has been entered
func _detected(_p: Node2D) -> void:
	seen.emit()


## Runs when the detection range has been exited
func _undetected(_p: Node2D) -> void:
	not_seen.emit()
