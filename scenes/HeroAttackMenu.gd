extends CanvasLayer

signal attack_launched(hero_name, target_node)
signal menu_closed

@onready var target_label = $Control/Panel/VBoxContainer/TargetLabel
@onready var hero_list_container = $Control/Panel/VBoxContainer/HeroContainer # You need a container for hero buttons/slots
@onready var matchup_label = $Control/Panel/VBoxContainer/MatchupLabel
@onready var btn_launch = $Control/Panel/VBoxContainer/BtnLaunch

var current_target = null
var selected_hero = "Kael" # Default to the starting hero

func _ready():
	visible = false

func open(encounter_node):
	current_target = encounter_node
	visible = true
	
	target_label.text = "Target: " + current_target.encounter_name + " (" + current_target.enemy_faction + ")"
	
	# For now, select Kael automatically
	_select_hero("Kael")
	
	# Later: Populate hero_list_container with buttons for all Heroes in HeroManager.owned_heroes

func _select_hero(hero_name):
	selected_hero = hero_name
	var hero_stats = HeroManager.get_hero_stats(hero_name)
	
	if hero_stats == null:
		print("Error: Hero stats not found for ", hero_name); return

	var player_faction = hero_stats.faction
	var enemy_faction = current_target.enemy_faction
	
	# 1. Determine Faction Matchup
	var matchup_text = "Your " + player_faction + " Hero vs. " + enemy_faction
	var mult = 1.0

	if GameData.faction_counters.get(player_faction) == enemy_faction:
		mult = 1.25
		matchup_text += "\n[color=green]FACTION ADVANTAGE: +25% POWER[/color]"
	elif GameData.faction_counters.get(enemy_faction) == player_faction:
		mult = 0.75
		matchup_text += "\n[color=red]FACTION DISADVANTAGE: -25% POWER[/color]"
	else:
		matchup_text += "\n[color=yellow]EVEN MATCHUP[/color]"

	# 2. Update UI
	matchup_label.text = matchup_text
	btn_launch.text = "Attack with " + hero_name + "!"


# --- BUTTON SIGNALS ---
func _on_btn_launch_pressed():
	if current_target and selected_hero:
		emit_signal("attack_launched", selected_hero, current_target)
		close()

func _on_btn_cancel_pressed():
	close()

func close():
	visible = false
	emit_signal("menu_closed")
