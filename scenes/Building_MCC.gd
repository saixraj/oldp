extends Area2D

# Signals
signal building_selected(node_ref)
signal level_changed(new_level)

# Variables
var building_name = "Command Center"
var current_level = 1

func _ready():
	input_pickable = true 
	# --- NEW: SYNC WITH SAVED LEVEL ---
	# Wait a tiny bit for SaveManager to finish loading
	await get_tree().create_timer(1.1).timeout
	
	current_level = Global.mcc_level
	print("MCC: Synced level to ", current_level)
	
	# If we are high level, restore the Gold look
	if current_level >= 6:
		update_visual_tier(2)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		emit_signal("building_selected", self)

func upgrade():
	var cost_scrap = 0
	var cost_wood = 0
	var cost_steel = 0
	var cost_planks = 0
	
	# --- 1. DETERMINE COSTS BASED ON LEVEL ---
	# (Logic based on your Excel sheet)
	
	if current_level < 6:
		# Early Game: Costs Scrap & Wood
		cost_scrap = current_level * 100
		cost_wood = current_level * 100
	else:
		# Mid Game (Level 6+): Costs Refined Resources
		# Example: Level 6 costs 500 Steel/Planks
		cost_steel = (current_level - 4) * 500
		cost_planks = (current_level - 4) * 500

	# --- 2. CHECK PAYMENT ---
	if Global.try_pay(cost_scrap, cost_wood, cost_steel, cost_planks):
		
		# Success! Level up.
		current_level += 1
		Global.update_mcc_level(current_level) # <--- Add this line
		emit_signal("level_changed", current_level)
		
		
		print("MCC Upgraded to Level ", current_level)
		
		# Increase Passive Income (Scrap/Wood)
		Global.increase_income(10) 
		
		# --- 3. CHECK FOR VISUAL EVOLUTION ---
		# Your notes say visuals change at Level 6
		if current_level == 6:
			update_visual_tier(2)
			
	else:
		print("Not enough resources!")
		print("Need: S:", cost_scrap, " W:", cost_wood, " ST:", cost_steel, " PL:", cost_planks)

func update_visual_tier(tier):
	print("--- VISUAL EVOLUTION: TIER ", tier, " ---")
	
	# Since you might not have art yet, we will tint it GOLD to show it evolved
	# Later, you will swap the texture: $Sprite2D.texture = load("res://mcc_tier_2.png")
	
	if tier == 2:
		# Change color to Gold/Yellow to represent Tier 2
		$Sprite2D.modulate = Color(1, 0.8, 0.2) 
		# Make it slightly bigger
		scale = Vector2(1.2, 1.2)
