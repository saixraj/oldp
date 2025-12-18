extends Node

# Signals (UI still listens to these!)
signal resources_updated(scrap, wood, steel, planks, dna)
signal army_updated(army_dict)
signal kills_updated(total_kills)

# Local State Cache (Updated by NetworkManager)
var scrap = 0
var wood = 0
var steel = 0
var planks = 0
var mutant_dna = 0

var army = {}
var mcc_level = 1
var kill_count = 0

# NOTE: No _process or Timer here! The server sends ticks.

func update_from_server(resource_proto, army_proto):
	# 1. Update Resources
	scrap = resource_proto.scrap
	wood = resource_proto.wood
	steel = resource_proto.steel
	mutant_dna = resource_proto.mutant_dna
	# Planks not in proto example, but you can add it
	
	emit_signal("resources_updated", scrap, wood, steel, planks, mutant_dna)
	
	# 2. Update Army
	army.clear()
	# iterating protobuf map
	for unit_name in army_proto.units:
		army[unit_name] = army_proto.units[unit_name]
		
	emit_signal("army_updated", army)
