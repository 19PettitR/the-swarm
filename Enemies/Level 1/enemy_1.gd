class_name enemy extends CharacterBody2D

## Basic variables related to the enemy: speed, strength, hitpoints, cooldown length
@export_category("Stats")
@export var speed : float = 290
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

var enemy_is_attacking : bool = false
# Stores whether the enemy's attack is on cooldown or not
var enemy_attack_cooldown : bool = false

# Stores the number of hitpoints the enemy has during the game
var enemy_hitpoints : int = max_enemy_hitpoints
var dead : bool = false
