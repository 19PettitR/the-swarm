class_name Player extends CharacterBody2D

@onready var dash_timer: Timer = $Dash
@onready var dash_cooldown_timer: Timer = $Dash_Cooldown
@onready var attack_timer: Timer = $Attack
@onready var attack_cooldown_timer: Timer = $Attack_Cooldown

@export var max_health : int = 100

## These variables are related to character movement, can be changed in the inspector panel
@export_category("Movement")
@export var speed : float = 300.0
@export var jump_speed : float = -420.0
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

# Tracks which direction the player was last facing for when the player dashes whilst stationary
var last_facing_right : int = true

var is_dashing : bool = false
var dash_cooldown : bool = false

var is_attacking : bool = false
var attack_cooldown : bool = false
var attack_strength : int = 1

var in_climbing_range : bool = false
var is_climbing : bool = false
# Stores which side the wall is on so that the player sprite will appear on the correct side whilst climbing
var climb_side : String
# Stores the vertical line where the wall is located so the player sprite will appear in correct position
var climb_position : float
# Stores the maximum and minimum height of the wall so that the player stops climbing when necessary
var climb_maximum : float
var climb_minimum : float


## Controls the movement of the player and inputs of the user
func _physics_process(delta: float) -> void:
	
	var direction = 0
	
	# Normal movement applies only if the player is not climbing
	if not is_climbing:
		
		# Gravity should apply if the player is not on the floor
		if not is_on_floor():
			# Gravity is applied differently if the player is dashing (for fun)
			if not is_dashing:
				velocity += get_gravity() * delta * gravity_multiplier
			else:
				velocity += get_gravity() * delta * dash_gravity_multiplier
		
		# If the user presses the dash key, check they are able to dash and make the player dash
		if Input.is_action_just_pressed("dash") and not dash_cooldown:
			
			# Handles the timers and variables related to dash
			# Timers cannot be used here else all physics process (input, movement) will be paused
			_dash()
			
			# If the player is not moving, decide which direction to move in
			if velocity.x == 0:
				# If the player was last facing right, dash to the right
				if last_facing_right:
					velocity.x = speed * dash_boost
				# If the player was last facing left, dash to the left
				else:
					velocity.x = speed * dash_boost * -1
			# If the player is moving, multiply their velocity by dash boost to increase it
			else:
				velocity.x = velocity.x * dash_boost
		
		# Find which direction the player is moving in
		direction = Input.get_axis("left", "right")
		# Normal movement should only apply if player is not dashing
		if not is_dashing:
			# If the player has a direction, they should move
			if direction:
				velocity.x = direction * speed
			# If the player does not have a direction, slow them until stationary
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
		
		# Setting the last_facing_right variable based on the last direction input
		if Input.is_action_just_pressed("right"):
			last_facing_right = true
		if Input.is_action_just_pressed("left"):
			last_facing_right = false
		
		if Input.is_action_just_pressed("jump"):
			# Without this line the player will be able to jump up the walls
			if is_on_floor():
				velocity.y = jump_speed
		
		# If the user presses the climb key, check they are able to climb and call the subroutine
		if Input.is_action_just_pressed("climb") and in_climbing_range:
			is_climbing = true
			_climb()
		
	# Climbing movement for when the player is climbing
	else:
		
		# Find which direction the player is moving in
		direction = Input.get_axis("up", "down")
		
		# If there is a direction (player is not stationary), move the player in that direction
		if direction:
			velocity.y = direction * speed
		# If there is no direction, slow the player til they are stationary
		else:
			move_toward(velocity.x, 0, speed)
		
		# Velocity.y should be changed to move the player along the wall
		velocity.y = direction * speed
		
		# If the user presses the jump input, propel the user off of the wall
		if Input.is_action_just_pressed("jump"):
			# If the player is on the right side of the wall, propel them to the right
			if climb_side == "right":
				# Jump_speed is negative, times by -1 to make it positive
				velocity.x = 2000
				velocity.y = 100
			else:
				velocity.x = -2000
				velocity.y = 100
			# if the player has jumped off the wall, they are no longer climbing
			is_climbing = false
		
		# If player moves above maximum or below minimum of the wall, stop them from climbing
		if global_position.y < climb_maximum:
			is_climbing = false
		elif global_position.y > climb_minimum:
			is_climbing = false
	
	# If the user presses the attack key, check they are able to attack and call the subroutine
	if Input.is_action_just_pressed("attack"): ## and not attack_cooldown:
		_attack()
	
	# This subroutine is required to cause the player to move
	move_and_slide()


## Handles the timers and variables surrounding the dash since timers should not be used in process subroutines
func _dash():
	
	is_dashing = true
	dash_cooldown = true
	
	dash_timer.start()
	await dash_timer.timeout
	is_dashing = false
	
	dash_cooldown_timer.start(dash_cooldown_length)
	await dash_cooldown_timer.timeout
	dash_cooldown = false


## Sets the variables for the player to be positioned correctly when climbing
func _climb():
	# When climbing a wall on the right side, player should be at the wall's position plus half their width
	if climb_side == "right":
		global_position.x = climb_position + 25
	# When climbing a wall on the left side, player should be at the wall's position minus half their width
	else:
		global_position.x = climb_position - 25
	
	# If the player is above the maximum climb position, place them on the wall at the maximum
	if global_position.y < climb_maximum:
		global_position.y = climb_maximum
	# If the player is below the minimum climb position, place them on the weall at the minimum
	elif global_position.y > climb_minimum:
		global_position.y = climb_minimum
	
	# Prevents the player from drifting along the wall
	velocity.y = 0


## Handles the player's attack
func _attack():
	pass
