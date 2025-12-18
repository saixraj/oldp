extends Node

signal hero_data_updated

var owned_heroes = {}

func _ready():
	if owned_heroes.is_empty():
		_add_default_hero("Kael")
		
func _add_default_hero(hero_name):
	if hero_name in GameData.hero_data:
		var base_stats = GameData.hero_data[hero_name]
		owned_heroes[hero_name] = {
			"level": 1,
			"xp": 0,
			"equipped_unit": "Soldier", 
			"base_hp": base_stats.get("base_hp", 100),
			"base_atk": base_stats.get("base_atk", 10),
			"base_def": base_stats.get("base_def", 5)
		}

func add_xp(hero_name, amount):
	if hero_name in owned_heroes:
		var hero = owned_heroes[hero_name]
		hero.xp += amount
		var required_xp = hero.level * 100
		if hero.xp >= required_xp:
			level_up_hero(hero_name)

func level_up_hero(hero_name):
	if hero_name in owned_heroes:
		var hero = owned_heroes[hero_name]
		hero.level += 1
		hero.xp = 0 
		hero.base_hp += 10
		hero.base_atk += 2
		print("HeroManager: ", hero_name, " leveled up to ", hero.level)
		emit_signal("hero_data_updated")

# --- WAR MODE BUFFS ---

func get_troop_buffs(hero_name):
	# Buffs format: { "UnitType": { "atk": 0.25, "def": 0.15 } }
	var buffs = { "Soldier": {}, "Tank": {}, "Ranger": {} }
	
	if hero_name in owned_heroes and hero_name in GameData.hero_data:
		var hero_info = GameData.hero_data[hero_name]
		var equipped_unit = owned_heroes[hero_name].equipped_unit
		
		if equipped_unit not in buffs: buffs[equipped_unit] = {}
		
		for skill in hero_info.skills:
			var mode = skill.troop_mode
			if mode.type == "buff_atk":
				buffs[equipped_unit]["atk"] = buffs[equipped_unit].get("atk", 0.0) + mode.value
			elif mode.type == "buff_def":
				buffs[equipped_unit]["def"] = buffs[equipped_unit].get("def", 0.0) + mode.value
			
	return buffs

# --- EXPLORATION MODE STATS ---

func get_hero_stats(hero_name):
	if hero_name in owned_heroes:
		var hero = owned_heroes[hero_name]
		return {
			"faction": GameData.hero_data[hero_name]["faction"],
			"hp": hero.base_hp,
			"atk": hero.base_atk,
			"def": hero.base_def
		}
	return null

func set_equipped_unit(hero_name, unit_type):
	if hero_name in owned_heroes and unit_type in GameData.unit_stats:
		owned_heroes[hero_name].equipped_unit = unit_type
		print(hero_name, " is now commanding ", unit_type)
		emit_signal("hero_data_updated")
