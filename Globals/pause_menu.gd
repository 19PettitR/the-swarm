extends Node

# Components of the pause menu
@onready var pause_menu : CanvasLayer = get_node("/root/Node2D/Pause Menu")
@onready var resume_button : TextureButton = get_node("/root/Node2D/Pause Menu/Control/VBoxContainer/Resume_Button")
@onready var return_button : TextureButton = get_node("/root/Node2D/Pause Menu/Control/VBoxContainer/Return_Button")

# Tracks whether the game is paused or not
var paused : bool = false


## Connect the button signals to their subroutines
func _ready() -> void:
	resume_button.pressed.connect(_unpause)
	return_button.pressed.connect(_return_to_menu)


## Every frame, check whether the paused action has happened
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		# Cannot pause in the menu
		if LevelManager.current_level != 0:
			if not paused:
				_pause()


## Pause the game
func _pause() -> void:
	pause_menu.visible = true
	resume_button.disabled = false
	return_button.disabled = false
	get_tree().paused = true


## Unpause the game
func _unpause() -> void:
	pause_menu.visible = false
	resume_button.disabled = true
	return_button.disabled = true
	get_tree().paused = false


## Handles returning to the main menu
func _return_to_menu() -> void:
	LevelManager.current_level = 0
	LevelManager.validation()
	_unpause()
