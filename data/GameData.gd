# GameData.gd
# This script holds all static data, acting as a central database for the game.
extends Node

# --- FACTION DATA (Used by Hero Combat) ---
var faction_counters = {
	"Arcanum": "Revenants",
	"Revenants": "Ironbound",
	"Ironbound": "Sanctified",
	"Sanctified": "Arcanum"
}

# --- HERO DATABASE (REQUIRED CRASH FIX) ---
var hero_data = {
	"Kael": {
		"faction": "Arcanum",
		"base_hp": 100,
		"base_atk": 10,
		"base_def": 5,
		"skills": [
			{ # Skill 1: Firestorm (Attack Buff)
				"name": "Firestorm",
				"hero_mode": { "type": "damage", "value": 50, "desc": "Deals 50 DMG" },
				"troop_mode": { "type": "buff_atk", "value": 0.25, "desc": "Equipped Unit +25% ATK" } # Increased buff for better testing
			},
			{ # Skill 2: Healing Aura (Defense Buff)
				"name": "Healing Aura",
				"hero_mode": { "type": "heal", "value": 30, "desc": "Heals self for 30 HP" },
				# NEW: Defense buff needed for next development step
				"troop_mode": { "type": "buff_def", "value": 0.15, "desc": "Equipped Unit +15% DEF" } 
			}
		]
	}
}

# --- UNIT TRINITY (RTS LAYER) ---
var unit_stats = {
	"Soldier": { 
		"type": "Infantry", "hp": 25, "attack": 4, "defense": 2, "speed": 10,
		# Low-tier unit: Raw resources only
		"cost_scrap": 50, "cost_wood": 0, "cost_steel": 0, "cost_planks": 0, "cost_dna": 0 
	},
	"Tank": { 
		"type": "Armor", "hp": 150, "attack": 25, "defense": 8, "speed": 5,
		# Mid-tier unit: Requires Refined Steel (assuming you'll set up a Wood->Planks process later)
		"cost_scrap": 100, "cost_wood": 0, "cost_steel": 100, "cost_planks": 0, "cost_dna": 0
	},
	"Ranger": { 
		"type": "Specialist", "hp": 40, "attack": 15, "defense": 1, "speed": 9,
		# High-tier unit: Requires Refined Planks AND Mutant DNA
		"cost_scrap": 0, "cost_wood": 0, "cost_steel": 0, "cost_planks": 50, "cost_dna": 75
	}
}

# --- BUILDING DATABASE ---
var building_stats = {
	"Barracks": { "hp": 500, "cost_scrap": 500, "cost_wood": 200, "cost_steel": 0, "cost_planks": 0, "req_level": 3 },
	"Smelter": { "hp": 300, "cost_scrap": 200, "cost_wood": 0, "cost_steel": 100, "cost_planks": 0, "req_level": 5 },
	"Command Center": { "hp": 2000, "cost_scrap": 0, "cost_wood": 0, "cost_steel": 0, "cost_planks": 0 }
}

# --- ENEMY DATABASE ---
var enemy_stats = {
	"Mutant Pack": {
		"type": "Infantry", "faction": "Revenants",
		"hp": 30, "attack": 4, "defense": 0, "speed": 8,
		"reward_scrap": 50, "reward_dna": 10, "hp_growth": 10, "att_growth": 2
	},
	"Iron Golem": {
		"type": "Armor", "faction": "Ironbound",
		"hp": 200, "attack": 15, "defense": 10, "speed": 3,
		"reward_scrap": 150, "reward_dna": 50, "hp_growth": 50, "att_growth": 5
	}
}

# --- TECH DATABASE ---
var tech_data = {
	"Unlock Tank": { "cost_dna": 100, "description": "Unlocks the heavy Tank unit." },
	"Unlock Ranger": { "cost_dna": 150, "description": "Unlocks the versatile Ranger unit." },
	"Scrap Efficiency": { "cost_dna": 200, "description": "Increases Scrap income by +5/sec." }
}
