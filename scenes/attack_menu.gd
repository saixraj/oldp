extends CanvasLayer

signal attack_launched(target_node)
signal menu_closed

@onready var target_label = $Control/Panel/VBoxContainer/TargetLabel
@onready var army_info_label = $Control/Panel/VBoxContainer/ArmyInfoLabel
@onready var stats_label = $Control/Panel/VBoxContainer/StatsLabel

var current_target = null

func _ready():
	visible = false

func open(target_node):
	current_target = target_node
	
	# 1. NAME
	var display_name = "Unknown Target"
	if "enemy_name" in target_node: display_name = target_node.enemy_name
	elif "player_name" in target_node: display_name = target_node.player_name
		
	target_label.text = "Target: " + display_name
	
	# 2. SCOUTING LOGIC
	var strength_text = ""
	var loot = 0
	
	# Check if it is a Player (RivalBase - uses a defense rating)
	if "defense_rating" in target_node: 
		strength_text = "Est. Rating: " + str(target_node.defense_rating)
		loot = target_node.lootable_scrap
		
	# Check if it is a Monster (EnemyUnit - uses combat stats)
	# FIX: Use the new HP/ATK stats instead of current_power
	elif "current_hp" in target_node:
		var hp = target_node.current_hp
		var atk = target_node.current_atk
		strength_text = "HP: " + str(hp) + " | ATK: " + str(atk)
		loot = target_node.reward_scrap
		
	stats_label.text = strength_text + "\nLoot: " + str(loot) + " Scrap"
	
	# 3. MY ARMY
	var soldiers = Global.army.get("Soldier", 0)
	var tanks = Global.army.get("Tank", 0)
	var rangers = Global.army.get("Ranger", 0) # Added Ranger
	army_info_label.text = "Your Forces:\n" + str(soldiers) + " Soldiers, " + str(tanks) + " Tanks, " + str(rangers) + " Rangers"
	
	visible = true

func _on_btn_attack_pressed():
	if current_target:
		emit_signal("attack_launched", current_target)
		close()

func _on_btn_cancel_pressed():
	close()

func close():
	visible = false
	emit_signal("menu_closed")
