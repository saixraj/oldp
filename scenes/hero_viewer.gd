extends CanvasLayer

signal return_requested

@onready var hero_name_label: Label = $Control/Panel/VBoxContainer/HeroNameLabel
@onready var level_label: Label = $Control/Panel/VBoxContainer/LevelLabel
@onready var stats_label: Label = $Control/Panel/VBoxContainer/StatsLabel
@onready var equip_label: Label = $Control/Panel/VBoxContainer/EquipLabel
@onready var skill_label: Label = $Control/Panel/VBoxContainer/SkillLabel
@onready var btn_level_up: Button = $Control/Panel/VBoxContainer/BtnLevelUp

var current_hero = "Kael" # Default to your starting hero

func _ready():
	visible = false
	HeroManager.connect("hero_data_updated", update_ui)

func open():
	visible = true
	update_ui()

func update_ui():
	# For simplicity, we only display the first hero, Kael
	if current_hero in HeroManager.owned_heroes:
		var hero = HeroManager.owned_heroes[current_hero]
		var base = GameData.hero_data[current_hero]
		
		hero_name_label.text = current_hero + " (" + base.faction + ")"
		level_label.text = "Level: " + str(hero.level) + " | XP: " + str(hero.xp) + "/" + str(hero.level * 100)
		
		# Display Stats
		stats_label.text = "HP: " + str(hero.base_hp) + "\nATK: " + str(hero.base_atk) + "\nDEF: " + str(hero.base_def)
		
		# Display Equipped Unit
		equip_label.text = "Commanding: " + hero.equipped_unit
		
		# Display Skills (Example for Skill 1)
		var skill_info = base.skills[0]
		var s_text = skill_info.name + "\n"
		s_text += "  [Hero Mode]: " + skill_info.hero_mode.desc + "\n"
		s_text += "  [Troop Mode]: " + skill_info.troop_mode.desc
		
		skill_label.text = s_text
		
		# Check if ready for level up
		if hero.xp >= hero.level * 100:
			btn_level_up.text = "LEVEL UP!"
			btn_level_up.disabled = false
		else:
			btn_level_up.text = "Level Up (Need " + str(hero.level * 100 - hero.xp) + " XP)"
			btn_level_up.disabled = true
	else:
		hero_name_label.text = "No Hero Available"

# --- BUTTONS ---

func _on_btn_level_up_pressed():
	HeroManager.level_up_hero(current_hero)

# Add a placeholder button to simulate gaining XP
func _on_btn_add_xp_pressed():
	HeroManager.add_xp(current_hero, 20)
	
func _on_btn_close_pressed():
	visible = false
	emit_signal("return_requested")
	
func _on_btn_equip_tank_pressed():
	# This function calls the manager to change the equipped unit
	HeroManager.set_equipped_unit(current_hero, "Tank")
	# The update_ui() function will automatically refresh the display
	update_ui()
