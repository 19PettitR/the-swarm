class_name AttackRange extends Area2D


## Connects the area entered signal to the necessary subroutine
func _ready() -> void:
	area_entered.connect(_hurt_player)


## Runs if the attack box has been entered
func _hurt_player(p: Node2D) -> void:
	# Check if the area that entered the attack box is the player hit box
	if p == PlayerManager.hit_box:
		# Player takes all damage if enemy attacks them and they are not attacking
		if self.get_parent().enemy_is_attacking and not PlayerManager.player.is_attacking:
			PlayerManager.player_health(-(self.get_parent().enemy_strength)+randi_range(-5, 5))
		# If the enemy and player 'bump' or if the player is attacking, take small amount of damage
		else:
			PlayerManager.player_health(-((self.get_parent().enemy_strength/2)+randi_range(-2, 4)))
