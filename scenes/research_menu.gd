extends CanvasLayer

signal menu_closed

@onready var dna_info_label: Label = $Panel/VBoxContainer/DnaInfoLabel
@onready var btn_soldier_up: Button = $Panel/VBoxContainer/BtnUpgradeSoldier
@onready var btn_unlock_tank: Button = $Panel/VBoxContainer/BtnUnlockTank
@onready var btn_efficiency: Button = $Panel/VBoxContainer/BtnEfficiency
@onready var btn_unlock_ranger: Button = $Panel/VBoxContainer/BtnUnlockRanger # Ranger Button

func _ready():
	visible = false

func open():
	visible = true
	update_ui()

func update_ui():
	# CRASH FIX: Use 'attack' stat instead of 'power'
	var s_atk = GameData.unit_stats["Soldier"]["attack"]
	dna_info_label.text = "DNA: " + str(Global.mutant_dna) + "\nSoldier Attack: " + str(s_atk)
	
	# Tank Check
	if "Unlock Tank" in Global.unlocked_techs:
		if btn_unlock_tank: btn_unlock_tank.disabled = true; btn_unlock_tank.text = "Tank Unlocked"
			
	# Ranger Check
	if btn_unlock_ranger: # Check if the button exists in your scene
		if "Unlock Ranger" in Global.unlocked_techs:
			btn_unlock_ranger.disabled = true
			btn_unlock_ranger.text = "Ranger Unlocked"
		else:
			btn_unlock_ranger.disabled = false
			btn_unlock_ranger.text = "Unlock Ranger (150 DNA)"
	
	# Efficiency Check
	if "Scrap Efficiency" in Global.unlocked_techs:
		if btn_efficiency: btn_efficiency.disabled = true; btn_efficiency.text = "Efficiency Active"

func _on_btn_unlock_tank_pressed(): 
	var tech_name = "Unlock Tank" 
	var cost = 100 
	if Global.mutant_dna >= cost: 
		Global.mutant_dna -= cost 
		Global.unlock_tech(tech_name) 
		Global.emit_signal("resources_updated", Global.scrap, Global.wood, Global.steel, Global.planks, Global.mutant_dna) 
		update_ui() 
	else: 
		print("Not enough DNA to unlock Tank!")

func _on_btn_upgrade_soldier_pressed():
	var cost = 50
	if Global.mutant_dna >= cost:
		Global.mutant_dna -= cost
		GameData.unit_stats["Soldier"]["attack"] += 1
		Global.emit_signal("resources_updated", Global.scrap, Global.wood, Global.steel, Global.planks, Global.mutant_dna)
		update_ui()

func _on_btn_unlock_ranger_pressed():
	if Global.unlock_tech("Unlock Ranger"): update_ui()

func _on_btn_efficiency_pressed():
	if Global.unlock_tech("Scrap Efficiency"): update_ui()

func _on_btn_close_pressed():
	visible = false
	emit_signal("menu_closed")
