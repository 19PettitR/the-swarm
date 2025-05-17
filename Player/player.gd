class_name Player extends CharacterBody2D

@export var max_health : int = 100

## These variables are related to character movement, can be changed in the inspector panel
@export_category("Movement")
@export var speed : float = 300.0
@export var jump_velocity : float = -420.0
@export var gravity_multiplier : float = 0.8
# The amount that the player is knocked back when they touch an enemy
@export var knockback_speed : float = 400.0

## These variables are related to dashing, can be changed in the inspector panel
@export_category("Dash")
# The amount that the player's velocity is multiplied by when they dash
@export var dash_boost : int = 5
# Increases the amount the player decelerates by when dashing so they aren't fast for too long
@export var dash_deceleration_multiplier : int = 100
@export var dash_gravity_multiplier : float = 0.2
@export var dash_cooldown_length : float = 3.0

## These variables are related to attacking, can be changed in the inspector panel
@export_category("Attack")
# The strength of the player when they spawn into the level (when the game loads)
@export var begin_attack_strength : int = 1
@export var attack_cooldown_length : float = 0.8

var inventory : Array[String] = []
var health : int = 100

var my_position : Vector2
var last_facing_right : int = true

var is_dashing : bool = false
var dash_cooldown : bool = false

var is_attacking : bool = false
var attack_cooldown : bool = false
var attack_strength : int = 1

var in_climbing_range : bool = false
var is_climbing : bool = false#
var climb_side : String
var climb_position : float
var climb_maximum : float
var climb_minimum : float


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
