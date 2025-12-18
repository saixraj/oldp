# GuildManager.gd
extends Node

# --- STATIC GUILD DATA ---

# Store player's guild info
var my_guild_data = {
	"id": "UTRS_GUILD_001",
	"name": "The Founding Fathers",
	"tag": "[FND]",
	"power_rating": 5000, 
	"members": {
		"PlayerID_1": "Owner",
		"PlayerID_2": "Officer",
		"PlayerID_3": "Member"
	},
	"rank": 1 
}

# Store data for rival guilds (The "Database")
var rival_guilds = {
	"RIV_001": {
		"name": "Shadow Legion",
		"tag": "[SHD]",
		"power_rating": 8500,
		"status": "Hostile"
	},
	"RIV_002": {
		"name": "Iron Dynasty",
		"tag": "[IDY]",
		"power_rating": 4200,
		"status": "Neutral"
	},
	"RIV_003": {
		"name": "Cyber Syndicate",
		"tag": "[CYB]",
		"power_rating": 6100,
		"status": "Hostile"
	},
	"RIV_004": {
		"name": "Wasteland Kings",
		"tag": "[WST]",
		"power_rating": 2900,
		"status": "Neutral"
	}
}

# --- FUNCTIONS ---

# Called to update the player's guild power based on real game stats
func update_my_guild_power():
	var total_troops = 0
	# Calculate total army size
	if Global.army:
		for unit in Global.army:
			total_troops += Global.army[unit]
	
	# Formula: Base score + Army Size
	var new_power = (Global.mcc_level * 1000) + (total_troops * 10)
	my_guild_data["power_rating"] = new_power
	print("GuildManager: My Guild Power updated to: ", new_power)

# Tracks kill counts for leaderboards
func log_guild_kill(target_tag):
	print("GuildManager: Logged kill against ", target_tag)
	# Future: You could increment a 'kills' counter here
	# my_guild_data.kills += 1

# Retrieves the top ranked guilds for display
func get_leaderboard_data():
	var leaderboard = []
	for id in rival_guilds:
		leaderboard.append(rival_guilds[id])
	
	# Add ourselves to the list
	update_my_guild_power()
	leaderboard.append(my_guild_data)
	
	# Sort Descending (Highest Power First)
	leaderboard.sort_custom(func(a, b): return a.power_rating > b.power_rating)
	
	return leaderboard.slice(0, 9) # Top 10
