extends CanvasLayer

# --- SIGNALS ---
signal enter_base_requested 
signal open_army_view_requested
signal open_research_requested
signal open_hero_view_requested # <--- NEW SIGNAL

# --- VARIABLES ---
@onready var title_label: Label = $Control/Panel/VBoxContainer/TitleLabel
@onready var level_label: Label = $Control/Panel/VBoxContainer/LevelLabel
@onready var upgrade_button: Button = $Control/Panel/VBoxContainer/UpgradeButton
@onready var enter_btn: Button = $Control/Panel/VBoxContainer/EnterBaseButton

@onready var scrap_label = $Control/TopBar/HBoxContainer/ScrapLabel 
@onready var wood_label = $Control/TopBar/HBoxContainer/WoodLabel   
@onready var steel_label = $Control/TopBar/HBoxContainer/SteelLabel
@onready var planks_label = $Control/TopBar/HBoxContainer/PlanksLabel 
@onready var dna_label: Label = $Control/TopBar/HBoxContainer/DnaLabel
@onready var btn_hero: Button = $Control/TopBar/HBoxContainer/BtnHero

@onready var raid_warning: Panel = $Control/RaidWarning
@onready var raid_label: Label = $Control/RaidWarning/Label

# --- NEW: LEADERBOARD SETUP ---
# 1. Load the blueprint
var leaderboard_scene = preload("res://scenes/Leaderboard.tscn") 
# 2. Variable to hold the actual window once we create it
var leaderboard_instance = null 

var current_building = null
var raid_timer = null
var incoming_power = 0

func _ready():
	$Control/Panel.visible = false
	
	update_resource_text(Global.scrap, Global.wood, Global.steel, Global.planks, Global.mutant_dna)
	
	Global.connect("resources_updated", update_resource_text)
	SaveManager.offline_gains_calculated.connect(_show_welcome_back_popup)

func _show_welcome_back_popup(scrap, wood, steel):
	if scrap == 0 and wood == 0: return 
	
	var msg = "Welcome Commander!\nWhile you were away, your drones produced:\n\n"
	msg += "+ " + str(scrap) + " Scrap\n"
	msg += "+ " + str(wood) + " Wood\n"
	if steel > 0: msg += "+ " + str(steel) + " Steel"
	
	OS.alert(msg, "Offline Report")
	
func _process(delta):
	if raid_warning.visible and raid_timer and not raid_timer.is_stopped():
		var time_left = int(raid_timer.time_left)
		raid_label.text = "WARNING!\nEnemy Power: " + str(incoming_power) + "\nImpact in: " + str(time_left) + "s"

func start_raid_countdown(enemy_power, duration):
	incoming_power = enemy_power
	raid_warning.visible = true
	
	raid_timer = Timer.new()
	raid_timer.wait_time = duration
	raid_timer.one_shot = true
	raid_timer.timeout.connect(_on_raid_impact)
	add_child(raid_timer)
	raid_timer.start()

func _on_raid_impact():
	raid_warning.visible = false
	
	var my_def = Global.get_defense_power()
	print("RAID HIT! Enemy: ", incoming_power, " vs My Defense: ", my_def)
	
	if my_def >= incoming_power:
		print("DEFENSE SUCCESSFUL! You repelled the invader.")
	else:
		print("DEFENSE FAILED! Your base was looted.")
		var lost_scrap = int(Global.scrap * 0.2) 
		Global.scrap -= lost_scrap
		Global.emit_signal("resources_updated", Global.scrap, Global.wood, Global.steel, Global.planks, Global.mutant_dna)
		print("Lost ", lost_scrap, " Scrap.")
	
	if raid_timer:
		raid_timer.queue_free()

func open_menu(building_node):
	current_building = building_node
	title_label.text = building_node.building_name
	level_label.text = "Level " + str(building_node.current_level)
	
	if enter_btn:
		enter_btn.visible = true
	
	$Control/Panel.visible = true

func update_resource_text(scrap_val, wood_val, steel_val, planks_val, dna_val):
	if scrap_label: scrap_label.text = "Scrap: " + str(scrap_val)
	if wood_label: wood_label.text = "Wood: " + str(wood_val)
	if steel_label: steel_label.text = "Steel: " + str(steel_val)
	if planks_label: planks_label.text = "Planks: " + str(planks_val)
	if dna_label: dna_label.text = "DNA: " + str(dna_val)

func _on_upgrade_button_pressed():
	if current_building:
		current_building.upgrade()
		level_label.text = "Level " + str(current_building.current_level)

func _on_enter_base_button_pressed():
	emit_signal("enter_base_requested")

func _on_btn_army_pressed():
	emit_signal("open_army_view_requested")
	
func _on_btn_research_pressed():
	emit_signal("open_research_requested")

# --- NEW: LEADERBOARD BUTTON LOGIC ---
# Make sure you connect your button to this function in the editor!
func _on_btn_leaderboard_pressed():
	print("UI: Leaderboard requested")
	
	# Check if we have created the window yet
	if leaderboard_instance == null:
		# If not, create it now!
		leaderboard_instance = leaderboard_scene.instantiate()
		add_child(leaderboard_instance)
	
	# Now we can safely open it
	leaderboard_instance.open()

func _on_btn_hero_pressed():
	emit_signal("open_hero_view_requested")
