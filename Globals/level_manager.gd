extends Node

## Emits a signal to run all necessary subroutine (respawn, etc.)
signal level_start

## The start positions for each level
var l1_start : Vector2 = Vector2(55,1891)
var l2_start : Vector2 = Vector2(4751, 1729)
var l3_start : Vector2 = Vector2(9393, 1885)

## The current level being played
var current_level : int = 1

## Variables used to validate save file
var save_file_valid : bool = true
var validate_length : bool = false
var validate_semicolons : bool = false
var validate_levels : bool = false
var validate_strength_items : bool = false
var validate_strength_variable : bool = false
var validate_collectibles : bool = false

## Each item in the game can access this array and check whether it has been collected
var item_status : Array[int] = [0,0,0,0,0,0,0,0,0,0,0]

## Position that objects should go to to be out of sight of the player (to "disappear")
var disappear_position : Vector2 = Vector2(120,2400)

## Checks save file exists, is in correct format. Replace if not.
func _ready() -> void:
	
	# Checks for a save file
	if FileAccess.file_exists("user://save_game.txt"):
		# Get the contents of the file to validate it
		var save_file = FileAccess.open("user://save_game.txt", FileAccess.READ_WRITE)
		var content = save_file.get_as_text()
		
		# Check save_file is the correct length
		if content.length() == 19:
			validate_length = true
		else:
			save_file_valid = false
			print("Length Invalid")
		
		# Check semi-colons are in correct places
		if content[3] == ";":
			if content[6] == ";":
				if content[11] == ";":
					validate_semicolons = true
		if not validate_semicolons:
			save_file_valid = false
			print("Semi-Colons Invalid")
		
		# Check first section; all 0s or 1s. Do not allow invalid level completion combinations
		if content[0] == "0":
			if content[1] == "0":
				if content[2] == "0":
					# No levels complete
					validate_levels = true
		elif content[0] == "1":
			if content[1] == "0":
				if content[2] == "0":
					# Level 1 complete
					validate_levels = true
			elif content[1] == "1":
				if content[2] == "0" or content[2] == "1":
					# Level 2 (and maybe 3) complete
					validate_levels = true
		if not validate_levels:
			save_file_valid = false
			print("Levels Invalid")
		
		# Check second section for integers
		if (int(content[4]) or content[4] == "0") and (int(content[5]) or content[5] == "0"):
				validate_strength_variable = true
		else:
			save_file_valid = false
			print("Strength Variable Invalid")
		
		# Check third section. Ensure all 0s or 1s
		if content[7] == "0" or content[7] == "1":
			if content[8] == "0" or content[8] == "1":
				if content[9] == "0" or content[9] == "1":
					if content[10] == "0" or content[10] == "1":
						validate_strength_items = true
		if not validate_strength_items:
			save_file_valid = false
			print("Strength Items Invalid")
		
		# Check fourth section. Ensures all 0s or 1s
		if content[12] == "0" or content[12] == "1":
			if content[13] == "0" or content[13] == "1":
				if content[14] == "0" or content[14] == "1":
					if content[15] == "0" or content[15] == "1":
						if content[16] == "0" or content[16] == "1":
							if content[17] == "0" or content[17] == "1":
								if content[18] == "0" or content[18] == "1":
									validate_collectibles = true
		if not validate_collectibles:
			save_file_valid = false
			print("Collectibles Invalid")
		
		# Make a new save file if current is invalid
		if not save_file_valid:
			save_file.resize(19)
			save_file.store_string("000;01;0000;0000000")
			save_file.close()
	
	# Make a new save file
	else:
		var save_file = FileAccess.open("user://save_game.txt", FileAccess.WRITE)
		save_file.store_string("000;01;0000;0000000")
		save_file.close()
		
	start_level(1)


# temporary, to test deletion
func _process(_delta) -> void:
	if Input.is_action_just_pressed("delete"):
		# Write a blank save file to delete all data
		var save_file = FileAccess.open("user://save_game.txt", FileAccess.WRITE)
		save_file.store_string("000;01;0000;0000000")
		save_file.close()
		print("data deleted")
		# Close the game
		get_tree().quit()


## Responsible for loading the player's begin_attack_strength and items
func _game_load() -> void:
	
	# Open the save file and read its contents to load data
	var save_file = FileAccess.open("user://save_game.txt", FileAccess.READ)
	var content = save_file.get_as_text()
	
	# Set the player's begin_attack_strength to the strength stored in the save file
	PlayerManager.player.begin_attack_strength = int(content[4]+content[5])

	# Loop through strengthening items, check whether each has been collected or not
	for i in range(0,4):
		# If the strengthening item has been collected
		if content[i+7] == "1":
			item_status[i] = 1
	# Loop through collectibles, check whether each has been collected or not
	for i in range(0,7):
		if content[i+12] == "1":
			item_status[i+4] = 1
	print(item_status)
	save_file.close()


## Handles starting/restarting the level
func start_level(l:int) -> void:
	
	# Change the current_level to the new one starting if necessary
	if current_level != l:
		current_level = l
	
	# Check which level is starting so player spawns at correct location
	if current_level == 1:
		PlayerManager.spawn(l1_start)
	elif current_level == 2:
		PlayerManager.spawn(l2_start)
	elif current_level == 3:
		PlayerManager.spawn(l3_start)
	
	print("level is now: ", current_level)
	# Update the player's begin attack strength and item collection status
	_game_load()
	# Emit a signal so respawn subroutines are run
	level_start.emit()


## Handles the when the player exits the level
func end_level(l:int) -> void:
	
	# Open the save file
	var save_file = FileAccess.open("user://save_game.txt", FileAccess.READ_WRITE)
	var content = save_file.get_as_text()
	
	# Save the level
	content[l-1] = "1"
	
	# Save the player strength
	var strength = PlayerManager.player.attack_strength
	# If the strength is one digit, also include "0" at the front
	if strength < 10:
		content[4] = "0"
		content[5] = str(strength)
	# If the strength is two digits, update both 'bits' separately
	else:
		content[4] = str(strength)[0]
		content[5] = str(strength)[1]
	
	# Saving the strength and collectible items
	# Position of the 'bit' that needs to be updated
	var position : int = 0
	for item in PlayerManager.player.inventory:
		# Check for / save strengthening items first
		if item.begins_with("ST"):
			position = int(item[2]+item[3]) + 7
			content[position] = "1"
		# Check for / save collectibles second
		if item.begins_with("CL"):
			position = int(item[2]+item[3]) + 12
			content[position] = "1"
	
	# Store the new save data
	save_file.store_string(content)
	save_file.close()
	print(content)
	
	# Call the start_level subroutine to start the new level if not on final level
	if l == 1 or l == 2:
		start_level(l+1)
	else:
		#temporary loop in levels for testing
		start_level(1)
		print("returned back to menu")
