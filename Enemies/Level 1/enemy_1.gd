class_name enemy extends CharacterBody2D

# Needed to detect when the enemy has been hit
@onready var hit_box: HitBox = $HitBox
# Needed to find when the player is in range
@onready var detection_range: DetectionRange = $DetectionRange
# Needed to chase the player
@onready var player = PlayerManager.player

## Basic variables related to the enemy: speed, strength, hitpoints, cooldown length
@export_category("Stats")
@export var speed : float = 180
@export var chase_speed : float = 250
@export var enemy_strength : float = 10
@export var max_enemy_hitpoints : int = 1
@export var enemy_attack_cooldown_length : float = 1.5

## Variables relating to the movement of the enemy: boundaries it cannot pass
@export_category("Movement Range")
@export var left_boundary : float
@export var right_boundary : float

## Variables relating to the attacking of the enemy: distance it can attack from
@export_category("Attack Range")
@export var vertical_attack_range : int
@export var horizontal_attack_range : int

# Stores the global_position of the enemy when they are first initialised
var my_position : Vector2
# Stores whether the player is in the detection range or not
var player_within_range : bool = false
# Stores which direction the player is relative to the enemy
var relative_player_direction : int
# The direction that the enemy is moving
var direction : int = 1

var enemy_is_attacking : bool = false
# Stores whether the enemy's attack is on cooldown or not
var enemy_attack_cooldown : bool = false

# Stores the number of hitpoints the enemy has during the game
var enemy_hitpoints : int = max_enemy_hitpoints
var dead : bool = false


## Connects the subroutines to their signals
func _ready() -> void:
	hit_box.take_damage.connect(_take_damage)
	detection_range.seen.connect(_player_seen)
	detection_range.not_seen.connect(_player_gone)


## Check whether the player can be attacked and updates relative_player_direction
func _process(_delta: float) -> void:
	
	# Player is to the right
	if player.global_position.x > global_position.x:
		relative_player_direction = 1
	# Player is to the left
	elif player.global_position.x < global_position.x:
		relative_player_direction = -1
	# Player is in same vertical line
	else:
		relative_player_direction = 0


## Responsible for all enemy movement
func _physics_process(delta: float) -> void:
	
	# Causes the enemy to fall and not remain static (only to be used when spawning)
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# If the player is not in range, the enemy should patrol up and down
	if not player_within_range:
		# If the enemy is further left of the left boundary, they should start moving right
		if global_position.x <= left_boundary:
			direction = 1
		# If the enemy is further right of the right boundary, they should start moving left
		elif global_position.x >= right_boundary:
			direction = -1
		velocity.x = speed * direction
	
	# If the player is in range, they should be followed
	else:
		# If player is to the left
		if relative_player_direction == -1:
			# If left boundary reached
			if global_position.x <= left_boundary:
				# Do not follow player
				direction = 0
			else:
				direction = -1
		# If player is to the right
		elif relative_player_direction == 1:
			# If right boundary reached
			if global_position.x >= right_boundary:
				# Do not follow player
				direction = 0
			else:
				direction = 1
		# If player is in the same vertical line, do not move
		else:
			direction = 0
		velocity.x = chase_speed * direction
	
	move_and_slide()


## Responsible for attacking the player
func _attack() -> void:
	pass


## Responsible for the enemy taking damage when it has been hit
func _take_damage() -> void:
	pass


## Responsible for handling the enemy's death
func _die() -> void:
	pass


## Responsible for resetting the enemy to its original state when the level is reset
func _respawn() -> void:
	pass


## Update player_within_range
func _player_seen():
	player_within_range = true


## Update player_within_range
func _player_gone():
	player_within_range = false
