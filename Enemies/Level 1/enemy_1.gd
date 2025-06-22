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
@export var enemy_attack_boost : int = 3

## Variables relating to the movement of the enemy: boundaries it cannot pass
@export_category("Movement Range")
@export var left_boundary : float
@export var right_boundary : float

## Variables relating to the attacking of the enemy: distance it can attack from
@export_category("Attack Range")
@export var v_attack_range : int
@export var h_attack_range : int

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
# Ensures that the enemy only takes damage once during player attacks
var enemy_immune : bool = false
var dead : bool = false

# Tracks whether the player is within the enemy's hitbox or not
var player_in_hitbox : bool


## Connects the subroutines to their signals
func _ready() -> void:
	# Signals related to enemy taking damage when player within hitbox
	hit_box.player_in_hitbox.connect(_check_for_damage)
	hit_box.player_not_in_hitbox.connect(_stop_checking_for_damage)
	# Signals related to enemy detecting player
	detection_range.seen.connect(_player_seen)
	detection_range.not_seen.connect(_player_gone)
	# Signal needed to control when the enemy can take damage
	player.attack_end.connect(_be_vulnerable)
	enemy_hitpoints = max_enemy_hitpoints


## Checks when player attacking/to be attacked, updates relative_player_direction
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
	
	# Damage should be taken if player attacks whilst in hitbox and enemy not immune
	if player_in_hitbox and not enemy_immune:
		if player.is_attacking:
			_take_damage()
			enemy_immune = true
	
	# Check whether the player is within the attack range
	if (player.global_position.y - global_position.y) < v_attack_range or (player.global_position.y - global_position.y) > -v_attack_range:
		if (player.global_position.x - global_position.x) < h_attack_range or (player.global_position.x - global_position.x) > -h_attack_range:
			print("attack")


## Responsible for all enemy movement
func _physics_process(delta: float) -> void:
	
	if not dead:
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


## Makes the enemy take damage when the player has attacked them
func _take_damage() -> void:
	# Kill the enemy if their hitpoints drop below 0
	if enemy_hitpoints - player.attack_strength <= 0:
		_die()
	# If the enemy does not die, take their hitpoints away
	else:
		enemy_hitpoints -= player.attack_strength


## Starts the enemy checking for damage to be taken
func _check_for_damage() -> void:
	player_in_hitbox = true

## Stop the enemy for checking for damage when player exits hitbox
func _stop_checking_for_damage() -> void:
	player_in_hitbox = false

## Makes the enemy vulnerable again when the player has stopped attacking
func _be_vulnerable():
	enemy_immune = false


## Responsible for handling the enemy's death
func _die() -> void:
	dead = true
	global_position.x = 120
	global_position.y = 2400


## Responsible for resetting the enemy to its original state when the level is reset
func _respawn() -> void:
	pass


## Update player_within_range
func _player_seen():
	player_within_range = true

## Update player_within_range
func _player_gone():
	player_within_range = false
