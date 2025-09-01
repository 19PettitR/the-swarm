extends Node

# The canvas layer
@onready var main_menu : CanvasLayer = get_node("/root/Node2D/Main Menu")

# Play and delete buttons
@onready var main_button_play : TextureButton = get_node("/root/Node2D/Main Menu/VBoxContainer/Play_Button")
@onready var main_button_delete : TextureButton = get_node("/root/Node2D/Main Menu/VBoxContainer/Delete_Button")

# Total collectible count
@onready var text_collectible_status : Label = get_node("/root/Node2D/Main Menu/Collectible Status/Collectible Status")

# Main menu panel background for each level status
@onready var mmp_level_1_2 : TextureRect = get_node("/root/Node2D/Main Menu/Main Menu Panel/MMP 12")
@onready var mmp_level_1 : TextureRect = get_node("/root/Node2D/Main Menu/Main Menu Panel/MMP 1")
@onready var mmp_empty : TextureRect = get_node("/root/Node2D/Main Menu/Main Menu Panel/MMP Empty")

# Level collectible statuses
@onready var level_collectibles : Control = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Collectibles")
@onready var coll_level_1 : Control = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Collectibles/Collectibles1")
@onready var coll_level_2 : Control = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Collectibles/Collectibles2")
@onready var coll_level_3 : Control = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Collectibles/Collectibles3")

# Level-specific collectible icons
@onready var icon_cl00 : TextureRect = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Collectibles/Collectibles1/Icon_CL00")
@onready var icon_cl01 : TextureRect = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Collectibles/Collectibles1/Icon_CL01")
@onready var icon_cl02 : TextureRect = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Collectibles/Collectibles2/Icon_CL02")
@onready var icon_cl03 : TextureRect = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Collectibles/Collectibles2/Icon_CL03")
@onready var icon_cl04 : TextureRect = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Collectibles/Collectibles3/Icon_CL04")
@onready var icon_cl05 : TextureRect = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Collectibles/Collectibles3/Icon_CL05")
@onready var icon_cl06 : TextureRect = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Collectibles/Collectibles3/Icon_CL06")

# Level play buttons
@onready var level_play_buttons : Control = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Play Buttons")
@onready var level_play_1 : TextureButton = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Play Buttons/LevelPlay1")
@onready var level_play_2 : TextureButton = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Play Buttons/LevelPlay2")
@onready var level_play_3 : TextureButton = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Play Buttons/LevelPlay3")

# Level names text
@onready var level_text : Control = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Text")
@onready var level_text_1 : Label = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Text/Level 1")
@onready var level_text_2 : Label = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Text/Level 2")
@onready var level_text_3 : Label = get_node("/root/Node2D/Main Menu/Main Menu Panel/Level Text/Level 3")

# Deletion confirmation
@onready var confirmation : Control = get_node("/root/Node2D/Main Menu/Main Menu Panel/Confirmation")
@onready var confirmation_tick : TextureButton = get_node("/root/Node2D/Main Menu/Main Menu Panel/Confirmation/Tick")

# Count the number of collectibles that have been found (to be displayed on menu)
var num_of_collectibles : int = 0
# Content of the save file
var content : String
var save_file : FileAccess


## Connect to button signals
func _ready() -> void:
	
	# Connect the button signals to subroutines
	main_button_play.pressed.connect(_main_play_button)
	main_button_delete.pressed.connect(_delete_button)
	level_play_1.pressed.connect(_level_1)
	level_play_2.pressed.connect(_level_2)
	level_play_3.pressed.connect(_level_3)
	confirmation_tick.pressed.connect(_data_deletion)


## Load necessary content from the save file
func menu_load() -> void:
	# Open the save file and read its contents to extract data
	save_file = FileAccess.open("user://save_game.txt", FileAccess.READ)
	content = save_file.get_as_text()
	save_file.close()
	
	# When the game is first run main menu will be nil
	if not main_menu:
		# Wait for all the objects to have loaded
		await get_tree().process_frame
	# If returning to menu after playing the game
	else:
		# Show the menu, enable the main buttons
		main_menu.visible = true
		main_button_play.disabled = false
		main_button_delete.disabled = false
		# Hide the mmp1 and mmp12 backgrounds (incase more levels complete)
		mmp_level_1.visible = false
		mmp_level_1_2.visible = false
		# Hide the collectibles
		coll_level_1.visible = false
		coll_level_2.visible = false
		coll_level_3.visible = false
		# Hide the play buttons
		level_play_1.visible = false
		level_play_2.visible = false
		level_play_3.visible = false
		# Hide the level text
		level_text_1.visible = false
		level_text_2.visible = false
		level_text_3.visible = false
	
	# Decide what needs to be displayed based on level completions
	# If no levels complete show just level 1
	if content[0] == "0":
		mmp_level_1.visible = true
		visible_level_1()
	# If only level 1 complete, show level 1 and 2
	elif content[1] == "0":
		mmp_level_1_2.visible = true
		visible_level_2()
	# If level 1&2 complete, show all levels
	else:
		visible_level_3()
	
	# Count and display correct icons for collectibles
	num_of_collectibles = 0
	if content[12] == "1":
		num_of_collectibles += 1
		icon_cl00.set_texture(ResourceLoader.load("res://Menus/Main Menu/Collectible Icon 2.png"))
	else:
		icon_cl00.set_texture(ResourceLoader.load("res://Menus/Main Menu/Collectible Not Found.png"))
	if content[13] == "1":
		num_of_collectibles += 1
		icon_cl01.set_texture(ResourceLoader.load("res://Menus/Main Menu/Collectible Icon 2.png"))
	else:
		icon_cl01.set_texture(ResourceLoader.load("res://Menus/Main Menu/Collectible Not Found.png"))
	if content[14] == "1":
		num_of_collectibles += 1
		icon_cl02.set_texture(ResourceLoader.load("res://Menus/Main Menu/Collectible Icon 2.png"))
	else:
		icon_cl02.set_texture(ResourceLoader.load("res://Menus/Main Menu/Collectible Not Found.png"))
	if content[15] == "1":
		num_of_collectibles += 1
		icon_cl03.set_texture(ResourceLoader.load("res://Menus/Main Menu/Collectible Icon 2.png"))
	else:
		icon_cl03.set_texture(ResourceLoader.load("res://Menus/Main Menu/Collectible Not Found.png"))
	if content[16] == "1":
		num_of_collectibles += 1
		icon_cl04.set_texture(ResourceLoader.load("res://Menus/Main Menu/Collectible Icon 2.png"))
	else:
		icon_cl04.set_texture(ResourceLoader.load("res://Menus/Main Menu/Collectible Not Found.png"))
	if content[17] == "1":
		num_of_collectibles += 1
		icon_cl05.set_texture(ResourceLoader.load("res://Menus/Main Menu/Collectible Icon 2.png"))
	else:
		icon_cl05.set_texture(ResourceLoader.load("res://Menus/Main Menu/Collectible Not Found.png"))
	if content[18] == "1":
		num_of_collectibles += 1
		icon_cl06.set_texture(ResourceLoader.load("res://Menus/Main Menu/Collectible Icon 2.png"))
	else:
		icon_cl06.set_texture(ResourceLoader.load("res://Menus/Main Menu/Collectible Not Found.png"))
	
	# Display total collectible count
	text_collectible_status.set_text(str(num_of_collectibles, "/7 COLLECTIBLES FOUND"))


## All level1-related UI made visible
func visible_level_1() -> void:
	level_text_1.visible = true
	level_play_1.visible = true
	coll_level_1.visible = true


## All level2-related UI made visible (+level 1)
func visible_level_2() -> void:
	level_text_2.visible = true
	level_play_2.visible = true
	coll_level_2.visible = true
	visible_level_1()


## All level3-related UI made visible (+level 2)
func visible_level_3() -> void:
	level_text_3.visible = true
	level_play_3.visible = true
	coll_level_3.visible = true
	visible_level_2()


## When play button is pressed, show level select
func _main_play_button() -> void:
	# If not on level select, show level select
	if mmp_empty.visible:
		mmp_empty.visible = false
		# Remove confirmation text & button if necessary
		if confirmation.visible:
			confirmation.visible = false
			confirmation_tick.disabled = true
		level_play_1.disabled = false
		level_play_2.disabled = false
		level_play_3.disabled = false


## When delete button is pressed, show confirmation
func _delete_button() -> void:
	# If on level select, show confirmation screen
	if not confirmation.visible:
		mmp_empty.visible = true
		confirmation.visible = true
		confirmation_tick.disabled = false
		# Disable all level select buttons
		level_play_1.disabled = true
		level_play_2.disabled = true
		level_play_3.disabled = true


## Start level 1 when button pressed
func _level_1() -> void:
	LevelManager.start_level(1)
	_hide_menu()


## Start level 2 when button pressed
func _level_2() -> void:
	LevelManager.start_level(2)
	_hide_menu()


## Start level 3 when button pressed
func _level_3() -> void:
	LevelManager.start_level(3)
	_hide_menu()


## Hide menu and disable all buttons when game started
func _hide_menu() -> void:
	main_menu.visible = false
	main_button_play.disabled = true
	main_button_delete.disabled = true
	level_play_1.disabled = true
	level_play_2.disabled = true
	level_play_3.disabled = true
	# Make the main menu panel empty for when returning to menu
	mmp_empty.visible = true


## Delete all data
func _data_deletion() -> void:
	save_file = FileAccess.open("user://save_game.txt", FileAccess.WRITE)
	save_file.store_string("000;01;0000;0000000")
	save_file.close()
	print("Data Deleted")
	get_tree().quit()
