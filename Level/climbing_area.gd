class_name Climbing_Area extends Area2D

# The side that the player climbs the wall
@export var climb_side : String
# The vertical line the wall makes up
@export var climb_position : float
# The top of the wall
@export var climb_maximum : float
# The bottom of the wall
@export var climb_minimum : float
# Tracks whether the player is inside a climbing area
var in_climbing_range : bool = false


## Connect signals to their subroutines
func _ready() -> void:
	body_entered.connect(_enter_climbing_area)
	body_exited.connect(_exit_climbing_area)

## Responsible for updating the player's climb variables when they enter the area
func _enter_climbing_area(_p : Node2D) -> void:
	in_climbing_range = true
	PlayerManager.update_climb(true, climb_side, climb_position, climb_maximum, climb_minimum)


## Responsible for updating the player's climb variables whn they exit the area
func _exit_climbing_area(_p : Node2D) -> void:
	in_climbing_range = false
	PlayerManager.update_climb(false)
