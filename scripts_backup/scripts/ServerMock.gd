extends Node

# Fake names for our "MMO"
var bot_names = ["LordVader", "Starkiller", "NoobSlayer", "EmpireBuilder", "Kratos", "Xenon", "IronHeart", "Viper", "Zeus", "Athena"]

func get_random_rival_data():
	var random_name = bot_names.pick_random() + str(randi_range(1, 99))
	var random_level = randi_range(1, 10)
	return {"name": random_name, "level": random_level}

# --- NEW: LEADERBOARD GENERATOR ---
func get_leaderboard_data():
	var leaderboard = []
	
	# 1. Create 9 Fake Players with random kills (close to player's level)
	var player_kills = Global.kill_count
	
	for i in range(9):
		var bot_name = bot_names.pick_random() + str(randi_range(1, 999))
		# Generate kills somewhat near the player's count to make it competitive
		var bot_kills = int(player_kills * randf_range(0.5, 1.5)) + randi_range(0, 50)
		leaderboard.append({"name": bot_name, "score": bot_kills, "is_me": false})
	
	# 2. Add YOU
	leaderboard.append({"name": "YOU", "score": player_kills, "is_me": true})
	
	# 3. Sort by Score (Descending)
	leaderboard.sort_custom(func(a, b): return a["score"] > b["score"])
	
	return leaderboard
