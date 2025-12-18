extends CanvasLayer

@onready var btn_soldier = $Control/Panel/VBoxContainer/BtnTrainSoldier
@onready var btn_tank = $Control/Panel/VBoxContainer/BtnTrainTank 
@onready var btn_ranger: Button = $Control/Panel/VBoxContainer/BtnTrainRanger # Make sure this button exists!

func _ready():
	visible = false

func open():
	visible = true
	_update_buttons()

# train_menu.gd (REPLACE the entire _update_buttons function)

func _update_buttons():
	# Retrieve costs from GameData (assuming GameData.unit_stats is structured with costs)
	var tank_costs = GameData.unit_stats["Tank"]
	var ranger_costs = GameData.unit_stats["Ranger"]
	
	# --- Tank Check ---
	if "Unlock Tank" in Global.unlocked_techs:
		if btn_tank: 
			btn_tank.disabled = false
			# NEW: Displaying Refined Costs (e.g., Steel)
			btn_tank.text = "Train Tank (" + str(tank_costs.cost_scrap) + " Scrap, " + str(tank_costs.cost_steel) + " Steel)"
	else:
		if btn_tank: btn_tank.disabled = true
		
	# --- Ranger Check ---
	if btn_ranger: # Check if the button exists
		if "Unlock Ranger" in Global.unlocked_techs:
			btn_ranger.disabled = false
			# NEW: Displaying Refined Costs (e.g., Planks, DNA)
			btn_ranger.text = "Train Ranger (" + str(ranger_costs.cost_planks) + " Planks, " + str(ranger_costs.cost_dna) + " DNA)"
		else:
			btn_ranger.disabled = true
			btn_ranger.text = "Ranger (Locked - Req Research)"

# --- BUTTON SIGNALS ---
func _on_btn_train_soldier_pressed():
	train_unit("Soldier")

func _on_btn_train_tank_pressed():
	if "Unlock Tank" in Global.unlocked_techs: train_unit("Tank")

func _on_btn_train_ranger_pressed(): # NEW BUTTON
	if "Unlock Ranger" in Global.unlocked_techs: train_unit("Ranger")

func _on_btn_close_pressed():
	visible = false

# --- HELPER FUNCTION ---
# train_menu.gd (REPLACE the entire train_unit function)

# --- HELPER FUNCTION ---
func train_unit(unit_name):
	if unit_name in GameData.unit_stats:
		var stats = GameData.unit_stats[unit_name]
		
		# Resource costs (read from GameData)
		var c_scrap = stats.get("cost_scrap", 0)
		var c_wood = stats.get("cost_wood", 0)
		var c_steel = stats.get("cost_steel", 0)
		var c_planks = stats.get("cost_planks", 0)
		var c_dna = stats.get("cost_dna", 0) # NEW: Get DNA cost
		
		# 1. CHECK & PAY ALL RESOURCES (Scrap, Wood, Steel, Planks)
		if Global.try_pay(c_scrap, c_wood, c_steel, c_planks):
			
			# 2. Check & Pay DNA separately (since try_pay only handles 4 resources)
			if Global.mutant_dna >= c_dna:
				Global.mutant_dna -= c_dna
				Global.emit_signal("resources_updated", Global.scrap, Global.wood, Global.steel, Global.planks, Global.mutant_dna)
				
				# SUCCESS
				Global.add_unit(unit_name, 1)
				print("TrainMenu: Trained 1 ", unit_name)
			else:
				# Revert payment if DNA is missing
				Global.scrap += c_scrap; Global.wood += c_wood; Global.steel += c_steel; Global.planks += c_planks
				Global.emit_signal("resources_updated", Global.scrap, Global.wood, Global.steel, Global.planks, Global.mutant_dna)
				print("TrainMenu: Not enough DNA for ", unit_name)
		else:
			print("TrainMenu: Not enough resources for ", unit_name)
