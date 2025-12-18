extends CanvasLayer

signal closed

# Preload the new separate LogViewer scene
var log_viewer_scene = preload("res://scenes/LogViewer.tscn")
var log_viewer_instance = null
var current_battle_log_text = "" # Stores the text so we can pass it to the popup later

@onready var title_label: RichTextLabel = $Control/Panel/VBoxContainer/TitleLabel
@onready var loot_label: RichTextLabel = $Control/Panel/VBoxContainer/LootLabel

# Side-by-Side Army Reports
@onready var player_army_label: RichTextLabel = $Control/Panel/VBoxContainer/HBoxContainer/PlayerArmyReport
@onready var enemy_army_label: RichTextLabel = $Control/Panel/VBoxContainer/HBoxContainer/EnemyArmyReport

# NEW BUTTON (Ensure you added this Button node in the scene and named it "BtnViewLog")
@onready var btn_view_log: Button = $Control/Panel/VBoxContainer/BtnViewLog


@onready var panel_bg = $Control/Panel


func _ready():
	visible = false
	# Connect the new button signal
	if btn_view_log:
		btn_view_log.visible = true

# --- VISIBILITY CONTROL ---

func show_troop_report_elements(is_troop_mode):
	# Show/Hide the army report labels
	if is_instance_valid(player_army_label): player_army_label.visible = is_troop_mode
	if is_instance_valid(enemy_army_label): enemy_army_label.visible = is_troop_mode
	
	# Show/Hide the log button (only relevant for troop battles)
	if is_instance_valid(btn_view_log): btn_view_log.visible = is_troop_mode


# --- TROOP BATTLE REPORT ---

# battle_result.gd (REPLACE the entire show_result function with this)

func show_result(is_victory, loot_amount, battle_log_array, initial_army, player_casualties):
	visible = true
	# Ensures the troop report elements (side-by-side reports, button) are visible
	show_troop_report_elements(true) 
	
	# 1. TITLE & LOOT
	if is_victory:
		title_label.text = "[center][color=#33FF33][u]VICTORY![/u][/color][/center]"
		loot_label.text = "Loot Stolen: [b]" + str(loot_amount) + " Scrap[/b]"
	else:
		title_label.text = "[center][color=red][u]DEFEAT...[/u][/color][/center]"
		loot_label.text = "Loot Stolen: [b]0[/b]"
		
	# --- 2. SIDE-BY-SIDE ARMY REPORTS (Player vs. Enemy) ---
	
	# A. PLAYER ARMY REPORT (Offensive Troops)
	var player_army_text = "[center][b][color=#104E8B]OFFENSIVE TROOPS[/color][/b][/center]\n"
	var total_deployed = 0
	var total_dead = 0
	
	for unit_name in initial_army:
		var initial_count = initial_army[unit_name]
		var dead_count = player_casualties.get(unit_name, 0)
		
		total_deployed += initial_count
		total_dead += dead_count
		
		if initial_count > 0:
			player_army_text += "\n[u]" + unit_name + "[/u]:\n"
			player_army_text += "  [color=green]Deployed:[/color] " + str(initial_count) + "\n"
			player_army_text += "  [color=red]Lost:[/color] " + str(dead_count) + "\n"

	player_army_text += "\n[u]TOTALS[/u]:\n"
	player_army_text += "  [color=green]Deployed:[/color] " + str(total_deployed) + "\n"
	player_army_text += "  [color=red]Losses:[/color] " + str(total_dead) + "\n"
	
	player_army_label.text = player_army_text
	
	# B. ENEMY ARMY REPORT (Defensive Forces)
	var enemy_name = "Target"
	# Tries to determine enemy name from the log data
	if battle_log_array.size() > 0 and battle_log_array[0].events.size() > 1:
		if battle_log_array[0].events[0].team == "Enemy":
			enemy_name = "Enemy Forces"
	
	var enemy_army_text = "[center][b][color=#8B0000]DEFENSIVE FORCES[/color][/b][/center]\n\n"
	enemy_army_text += "[u]" + enemy_name + "[/u]:\n"
	
	if is_victory:
		enemy_army_text += "  [color=red]Defeated:[/color] [b]YES[/b]\n"
		enemy_army_text += "  [color=red]Losses:[/color] [b]100%[/b]"
	else:
		enemy_army_text += "  [color=green]Defeated:[/color] [b]NO[/b]\n"
		enemy_army_text += "  [color=green]Losses:[/color] [b]0%[/b]"

	enemy_army_label.text = enemy_army_text

	
	# --- 3. GENERATE DETAILED BATTLE LOG (Stored for popup) ---
	var detailed_report_text = "[center][b]DETAILED BATTLE LOG[/b][/center]"
	
	for round_data in battle_log_array:
		detailed_report_text += "\n[b][color=yellow]-- ROUND " + str(round_data.round) + " --[/color][/b]\n"
		
		for event in round_data.events:
			var team = event.team
			var dmg = event.damage_dealt
			var kills = event.final_kill_count
			var mult = event.rps_multiplier
			
			var line = "  [color=white]" + team + "[/color] dealt [b]" + str(dmg) + " DMG[/b]."
			
			if mult == 1.5:
				line += " ([color=green]RPS Advantage![/color])"
			elif mult == 0.75:
				line += " ([color=red]RPS Disadvantage![/color])"
				
			line += "\n  " + "Caused [color=red]" + str(kills) + " casualties.[/color]"
			
			detailed_report_text += line + "\n"
			
	# Store the text variable for the popup to use
	
	current_battle_log_text = detailed_report_text
	# >>>>>>>>>>>>> ADD THIS DEBUG LINE <<<<<<<<<<<<<<<
	print("--- LOG DEBUG: Generated Log Content (Start) ---")
	print(current_battle_log_text)
	print("--- LOG DEBUG: Generated Log Content (End) ---")
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	
	# Ensure button visibility (we corrected the logic earlier, this is just a fail-safe)
	if btn_view_log:
		btn_view_log.visible = true

# --- HERO BATTLE REPORT ---

func show_hero_result(is_victory, hero_name, xp_gain, multiplier):
	visible = true
	
	show_troop_report_elements(false) # Hide troop elements (including button)
	
	# 1. Title
	if is_victory:
		title_label.text = "[center][color=#33FF33][u]" + hero_name + " - VICTORY![/u][/color][/center]"
	else:
		title_label.text = "[center][color=red][u]" + hero_name + " - DEFEAT...[/u][/color][/center]"
	
	# 2. Loot/Reward
	if is_victory:
		loot_label.text = "XP Gained: [b]" + str(xp_gain) + "[/b]"
	else:
		loot_label.text = "XP Gained: [b]0[/b]"

	# 3. Matchup Info (Using Player Label area)
	var matchup_text = "[center][b]FACTION MATCHUP[/b][/center]\n\n"
	matchup_text += "Multiplier: [b]" + str(multiplier) + "x[/b]\n"
	
	if multiplier > 1.0:
		matchup_text += "([color=green]Faction Advantage[/color])"
	elif multiplier < 1.0:
		matchup_text += "([color=red]Faction Disadvantage[/color])"
	else:
		matchup_text += "([color=yellow]Even Matchup[/color])"
		
	player_army_label.text = matchup_text
	player_army_label.visible = true # Explicitly show this one label for info


# --- BUTTON SIGNALS ---

func _on_btn_view_log_pressed():
	# Instantiate and show the popup
	if log_viewer_instance == null:
		log_viewer_instance = log_viewer_scene.instantiate()
		add_child(log_viewer_instance)
		
	log_viewer_instance.show_log(current_battle_log_text)

func _on_btn_close_pressed():
	visible = false
	emit_signal("closed")
