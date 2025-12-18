extends Area2D

signal enemy_clicked(enemy_node)

@export var enemy_name = "Mutant Pack" 
@export var level = 1

# Variables to store calculated stats
var current_hp = 0 # NEW
var current_atk = 0 # NEW
var reward_scrap = 0

func _ready():
	input_pickable = true
	_load_stats()

func _load_stats():
	# 1. Look up stats in GameData
	if enemy_name in GameData.enemy_stats:
		var stats = GameData.enemy_stats[enemy_name]
		
		# 2. Calculate HP
		var base_hp = stats["hp"]
		var hp_grow = stats["hp_growth"]
		current_hp = base_hp + (hp_grow * (level - 1))
		
		# 3. Calculate ATK
		var base_atk = stats["attack"]
		var atk_grow = stats["att_growth"]
		current_atk = base_atk + (atk_grow * (level - 1))
		
		# 4. Set Rewards
		reward_scrap = stats["reward_scrap"] * level
		
		print("Enemy Spawned: ", enemy_name, " Lvl ", level, " | HP: ", current_hp, " ATK: ", current_atk)
	else:
		print("Error: Enemy ", enemy_name, " not found in GameData!")

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Enemy Clicked: ", enemy_name)
		get_viewport().set_input_as_handled()
		emit_signal("enemy_clicked", self)
