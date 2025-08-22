class_name Enemy extends CharacterBody2D

# Needed to detect when the enemy has been hit
@onready var hit_box: HitBox = $HitBox
# Needed to find when the player is in range
@onready var detection_range: DetectionRange = $DetectionRange
# Needed to attack the player
@onready var attack_box: AttackBox = $"Attack Box"
# Needed to chase the player
@onready var player = PlayerManager.player
# Modulate the enemy when it has been hit
@onready var sprite: Sprite2D = $Sprite2D

# Timers for controlling enemy attack and enemy hit
@onready var enemy_attack_timer: Timer = $"Enemy Attack Timer"
@onready var enemy_attack_cooldown_timer: Timer = $"Enemy Attack Cooldown Timer"
@onready var hit_timer: Timer = $"Hit Timer"

## Basic variables related to the enemy
@export_category("Stats")
@export var speed : float = 180
@export var chase_speed : float = 250
@export var enemy_strength : float = 10
@export var max_enemy_hitpoints : int = 1
@export var knockback_multiplier : int = -2

## Variables relating to the enemy's attack
@export_category("Attack")
# Used to calculate the chance of an enemy attacking
@export var enemy_attack_chance : int = 100
@export var enemy_attack_cooldown_length : float = 1.5
@export var enemy_attack_boost : float = 3

## Variables relating to the movement of the enemy: boundaries it cannot pass
@export_category("Movement Range")
@export var left_boundary : float
@export var right_boundary : float

# Stores the global_position of the enemy when they are first initialised
var my_position : Vector2
# Stores whether the player is in the detection range or not
var player_within_range : bool = false
# Stores which direction the player is relative to the enemy
var relative_player_direction : int
# The direction that the enemy is moving
var direction : int = 1
# Tracks whether the enemy is at a door or not
var at_door : bool = false

# Stores whether the player can be attacked (if they are within attack range)
var enemy_can_attack : bool = false
var enemy_is_attacking : bool = false
# Stores whether the enemy's attack is on cooldown or not
var enemy_attack_cooldown : bool = false

# Stores the number of hitpoints the enemy has during the game
var enemy_hitpoints : int = max_enemy_hitpoints
# Ensures that the enemy only takes damage once during player attacks
var enemy_immune : bool = false
var enemy_hit : bool = false
var dead : bool = false

# Tracks whether the player is within the enemy's hitbox or not
var player_in_hitbox : bool


## Connects the subroutines to their signals
func _ready() -> void:
	
	# Signals related to enemy taking damage when player within hitbox
	hit_box.player_in_hitbox.connect(_check_for_damage)
	hit_box.player_not_in_hitbox.connect(_stop_checking_for_damage)
	# Signal needed to control when the enemy can take damage
	player.attack_end.connect(_be_vulnerable)
	
	# Signals related to enemy detecting player
	detection_range.seen.connect(_player_seen)
	detection_range.not_seen.connect(_player_gone)
	
	# Signals related to enemy being able to attack player
	attack_box.can_attack.connect(_look_to_attack)
	attack_box.cannot_attack.connect(_stop_looking_to_attack)
	
	# enemy_hitpoints needs to be set during _ready because max_enemy_hitpoints is export
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


## Responsible for all enemy movement
func _physics_process(delta: float) -> void:
	
	if not dead:
		# Causes the enemy to fall and not remain static (only to be used when spawning)
		if not is_on_floor():
			velocity += get_gravity() * delta
		# Knockback takes priority over other movement
		if not enemy_hit:
			# Must turn around at a door, else enemy will become stuck
			if not at_door:
				# Normal chasing and patrolling when the enemy is not attacking
				if not enemy_is_attacking:
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
						
						# Random chance of the enemy attacking
						if enemy_can_attack and not enemy_attack_cooldown:
							# A 1 in [enemy_attack_chance] chance of the enemy attacking
							if randi_range(1, enemy_attack_chance) == 1:
								# Call a subroutine to handle the attack timings
								_attack_timings()
								# Cause the enemy to lunge at the player; overwrites previous velocity.x
								velocity.x = velocity.x * enemy_attack_boost
								velocity.y = randi_range(-400, -50)
				
				# If enemy_is_attacking
				else:
					# Prevent the enemy from leaving their boundary
					if global_position.x <= left_boundary or global_position.x >= right_boundary:
						velocity.x = 0
			# If the enemy is at a door
			else:
				# Move like normal, direciton will be away from the door
				velocity.x = speed * direction
				# If distance between boundary and door is less than detection range
				if global_position.x <= left_boundary or global_position.x >= right_boundary:
					at_door = false
				# Once player is not detected, normal movement resumes
				if not player_within_range:
					at_door = false
		# If enemy has been hit (during knockback)
		else:
			# Prevent the enemy from leaving their boundary
			if global_position.x <= left_boundary or global_position.x >= right_boundary:
				velocity.x = 0
		
		move_and_slide()


## Responsible for handling timings when attacking the player
func _attack_timings() -> void:
	
	# Start the enemy attacking by changing the variables
	enemy_is_attacking = true
	enemy_attack_cooldown = true
	
	# Handle the timer for when the enemy is actively attacking
	enemy_attack_timer.start()
	await enemy_attack_timer.timeout
	enemy_is_attacking = false
	
	# Handle the enemy attack's cooldown timer
	enemy_attack_cooldown_timer.start(enemy_attack_cooldown_length)
	await enemy_attack_cooldown_timer.timeout
	enemy_attack_cooldown = false


## Allows the enemy to check to attack the player
func _look_to_attack() -> void:
	enemy_can_attack = true

## Stops the enemy from checking to attack the player
func _stop_looking_to_attack() -> void:
	enemy_can_attack = false


## Makes the enemy take damage when the player has attacked them
func _take_damage() -> void:

	# Kill the enemy if their hitpoints drop below 0
	if enemy_hitpoints - player.attack_strength <= 0:
		_die()
	# If the enemy does not die, take their hitpoints away
	else:
		enemy_hitpoints -= player.attack_strength
		
		# Set enemy_hit so that the physics process subroutine causes the enemy to be knocked back
		enemy_hit = true
		# Make the enemy pink so the player knows they have been hit and cannot be hit again
		sprite.set_modulate("pink")
		# Cause the enemy to fly backwards at 2 times their original velocity.x
		velocity.x = velocity.x * knockback_multiplier
		velocity.y = randi_range(-300, -100)
		# The knockback should last the length of hit_timer
		hit_timer.start()
		await hit_timer.timeout
		enemy_hit = false


## Makes the enemy turn around when they reach a door (so they dont get stuck)
func turn_around():
	at_door = true
	direction = direction * -1


## Starts the enemy checking for damage to be taken
func _check_for_damage() -> void:
	player_in_hitbox = true

## Stop the enemy for checking for damage when player exits hitbox
func _stop_checking_for_damage() -> void:
	player_in_hitbox = false

## Makes the enemy vulnerable again when the player has stopped attacking
func _be_vulnerable():
	enemy_immune = false
	# Enemy will be pink if they have been hit; they should return to original colour
	sprite.set_modulate("white")


## Responsible for handling the enemy's death
func _die() -> void:
	dead = true
	global_position = LevelManager.disappear_position


## Responsible for resetting the enemy to its original state when the level is reset
func _respawn() -> void:
	pass


## Update player_within_range
func _player_seen():
	player_within_range = true

## Update player_within_range
func _player_gone():
	player_within_range = false
