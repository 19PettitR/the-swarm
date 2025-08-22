extends Node

# Count the number of collectibles that have been found (to be displayed on menu)
var num_of_collectibles : int = 0

## Get the level and collectibles data from the level manager
func _ready() -> void:
	# Open the save file and read its contents to extract data
	var save_file = FileAccess.open("user://save_game.txt", FileAccess.READ)
	var content = save_file.get_as_text()
	
	# Output whether each level has been complete or not (temporary)
	if content[0] == "1":
		print("Level 1 Complete")
	else:
		print("Level 1 Not Complete")
	if content[1] == "1":
		print("Level 2 Complete")
	else:
		print("Level 2 Not Complete")
	if content[2] == "1":
		print("Level 3 Complete")
	else:
		print("Level 3 Not Complete")
	
	# Loop through collectibles, output whether each has been collected or not (temporary)
	for i in range(0,7):
		# If the collectible has been collected
		if content[i+12] == "1":
			print("CL0" + str(i) + " has been collected.")
			num_of_collectibles += 1
		# If the collectible has not been collected
		else:
			print("CL0" + str(i) + " has not been collected.")
	# Total count of collectibles (will be displayed on the menu)
	print("Total collectible count: " + str(num_of_collectibles))
	save_file.close()
