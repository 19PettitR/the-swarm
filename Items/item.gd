class_name Item extends Area2D

@onready var player = PlayerManager.player

@export var item_id : String = "1"
@export var item_strength : int = 2
@export var item_heal : int = 3

var collected : bool = false
var my_position : Vector2


func _ready() -> void:
	body_entered.connect(_collection)


func _collection(p:Node2D) -> void:
	if p == player:
		PlayerManager.item_add(item_id, item_strength, item_heal)
		global_position.x = 120
		global_position.y = 2400
