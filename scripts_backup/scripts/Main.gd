# Main.gd
extends Node2D

@onready var ui = $GameUI
@onready var world_map = $WorldMap 
@onready var army_viewer = $ArmyViewer  
@onready var inner_base = $InnerBase
@onready var attack_menu = $AttackMenu
@onready var battle_result_ui: CanvasLayer = $BattleResult
@onready var research_menu: CanvasLayer = $Research

# --- HERO UI SCENES ---
var hero_viewer_scene = preload("res://scenes/HeroViewer.tscn")
var hero_viewer_instance: CanvasLayer = null

var hero_attack_menu_scene = preload("res://scenes/HeroAttackMenu.tscn")
var hero_attack_menu_instance: CanvasLayer = null

func _ready():
	inner_base.visible = false       
	world_map.visible = true 

	# --- SIGNAL CONNECTIONS ---
	# Connecting UI signals
	ui.enter_base_requested.connect(_on_enter_base)
	ui.connect("open_army_view_requested", _on_open_army_view)
	army_viewer.connect("return_requested", _on_return_from_army)
	ui.open_research_requested.connect(_on_open_research_view)
	ui.connect("open_hero_view_requested", _on_open_hero_view)
	
	attack_menu.attack_launched.connect(_on_attack_launched)
	inner_base.return_to_map_requested.connect(_on_return_to_map)
	
	# Note: WorldMap signals (request_attack_menu, etc.) are connected 
	# via the Editor or automatically if you re-instantiated the scene.

# --- 1. WORLD MAP SIGNAL HANDLERS ---

func _on_world_map_request_menu(building_node):
	print("Main: Map requested Build Menu for ", building_node.name)
	ui.open_menu(building_node)

func _on_world_map_request_attack_menu(target_node):
	print("Main: Map requested Attack Menu for ", target_node.name)
	attack_menu.open(target_node)

func _on_world_map_request_hero_encounter(encounter_node):
	print("Main: Map requested Hero Encounter")
	_handle_hero_encounter_logic(encounter_node)

func _on_world_map_tile_clicked(grid_pos):
	print("Main: Player clicked empty tile at: ", grid_pos)


# --- 2. TROOP COMBAT (WAR MODE) ---

func _on_attack_launched(target):
	print("Main: Launching Combat System...")
	
	var initial_army = Global.army.duplicate(true) 
	
	# 1. GET HERO BUFFS
	var commander_name = "Kael" 
	var troop_buffs = HeroManager.get_troop_buffs(commander_name) 
	
	# 2. RUN BATTLE SIMULATION
	var result = CombatSystem.simulate_battle(Global.army, target, troop_buffs)
	
	var is_victory = result["victory"]
	var casualties = result["casualties"]
	
	# 3. REMOVE DEAD UNITS
	for unit in casualties:
		Global.remove_unit(unit, casualties[unit])
	
	# 4. HANDLE REWARDS & RESULT UI
	if is_victory:
		print("RESULT: VICTORY")
		var scrap_gain = 0
		var dna_gain = 0
		
		# PVE (Monsters)
		if "enemy_name" in target:
			scrap_gain = target.reward_scrap
			dna_gain = GameData.enemy_stats[target.enemy_name].get("reward_dna", 0)
			Global.add_kills(1)
			target.queue_free()
			
		# PVP / GUILD (Rival Bases)
		elif "defense_rating" in target:
			scrap_gain = target.lootable_scrap
			dna_gain = target.lootable_dna
			Global.add_kills(10)
			# target.defeat() # Uncomment if RivalBase has a defeat method
			
			# --- MMO GUILD LOGIC START ---
			# Only run this if the target has a Guild ID attached
			if target.has_meta("guild_id"):
				var target_guild_id = target.get_meta("guild_id")
				
				# Safety check: ensure the ID exists in our database
				if target_guild_id in GuildManager.rival_guilds:
					var guild_info = GuildManager.rival_guilds[target_guild_id]
					GuildManager.log_guild_kill(guild_info["tag"])
			# --- MMO GUILD LOGIC END ---

		Global.scrap += scrap_gain
		Global.mutant_dna += dna_gain
		Global.emit_signal("resources_updated", Global.scrap, Global.wood, Global.steel, Global.planks, Global.mutant_dna)
		
		battle_result_ui.show_result(true, scrap_gain, result["log"], initial_army, casualties) 
	else:
		print("RESULT: DEFEAT")
		battle_result_ui.show_result(false, 0, result["log"], initial_army, casualties)


# --- 3. HERO COMBAT (EXPLORATION MODE) ---

func _handle_hero_encounter_logic(encounter_node):
	if hero_attack_menu_instance == null:
		hero_attack_menu_instance = hero_attack_menu_scene.instantiate()
		add_child(hero_attack_menu_instance)
		hero_attack_menu_instance.attack_launched.connect(_launch_hero_battle)
	
	hero_attack_menu_instance.open(encounter_node)

func _launch_hero_battle(hero_name, target):
	print("Main: Launching Hero Combat...")
	
	var hero_stats = HeroManager.get_hero_stats(hero_name)
	if hero_stats == null: return

	# 1. Simulate
	var result = CombatSystem.simulate_hero_battle(hero_stats.faction, target.enemy_faction)
	var is_victory = result["victory"]
	var multiplier = result["power_multiplier"]
	var xp_reward = target.xp_reward 
	
	# 2. Result
	if is_victory:
		HeroManager.add_xp(hero_name, xp_reward)
		target.defeat()
		battle_result_ui.show_hero_result(true, hero_name, xp_reward, multiplier)
	else:
		battle_result_ui.show_hero_result(false, hero_name, 0, multiplier)


# --- 4. NAVIGATION & UI HANDLERS ---

func _on_open_research_view():
	research_menu.open()

func _on_enter_base():
	world_map.visible = false
	ui.get_node("Control/Panel").visible = false
	inner_base.visible = true

func _on_open_hero_view():
	if hero_viewer_instance == null:
		hero_viewer_instance = hero_viewer_scene.instantiate()
		add_child(hero_viewer_instance)
		hero_viewer_instance.connect("return_requested", _on_return_from_hero)
	
	world_map.visible = false
	inner_base.visible = false
	ui.visible = false 
	army_viewer.visible = false
	
	hero_viewer_instance.open()

func _on_return_from_hero():
	hero_viewer_instance.visible = false
	ui.visible = true
	inner_base.visible = true 

func _on_return_to_map():
	inner_base.visible = false
	world_map.visible = true
	
func _on_open_army_view():
	world_map.visible = false
	inner_base.visible = false
	ui.visible = false 
	army_viewer.visible = true
	
func _on_return_from_army():
	army_viewer.visible = false
	ui.visible = true
	inner_base.visible = true
