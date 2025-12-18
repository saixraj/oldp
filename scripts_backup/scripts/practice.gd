extends Node

class_name BS

func calc_round_dmg(attacker_info: Dictionary, def_info: Dictionary) -> float:
	var totaldmg = 0
	var def_defense = def_info.get("base_castle_def", 0.0)
	for troop_data in attacker_info:
		var troop_d = troop_data.data
		var quantity = troop_data.troop_quantity
		if quantity <= 0:
			continue
		#effective att
		var attbuff = attacker_info.get("commander_buff", 0.0)
		var effective_att = troop_d.base_att * attbuff
		
		var rps_multiplier = get_rps_multiplier(troop_d.troop_class, "heavies")
		var base_dmg = effective_att - (def_defense.defense/2)
		total_dmg += base_dmg * quantity * rps_multiplier
		
	return totaldmg * randf_range(0.98, 1.02)

func get_rps_multiplier(classA: string, classB: string)-> float:
	if classA == classB: return 1.0
	elif 
