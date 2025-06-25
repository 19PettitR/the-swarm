class_name AttackBox extends Area2D


## Connects the area entered signal to the necessary subroutine
func _ready() -> void:
	area_entered.connect(_hurt_player)


## Runs if the attack box has been entered
func _hurt_player(p: Node2D) -> void:
	# Check if the area that entered the attack box is the player hit box
	if p == PlayerManager.hit_box:
		# Player should not take damage whilst attacking the enemy
		if not PlayerManager.player.is_attacking:
			# If the enemy is attacking during collision, player takes their strength as damage
			if self.get_parent().enemy_is_attacking:
				PlayerManager.player_health(-self.get_parent().enemy_strength)
			# If the enemy and player bump, damage is half strength and slightly randomised
			else:
				PlayerManager.player_health(-((self.get_parent().enemy_strength/2)+randi_range(-2, 4)))
