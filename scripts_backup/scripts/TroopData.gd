# TroopData.gd (This defines a template for all troops)
extends Resource
class_name TroopData

@export var troop_name: String
@export var troop_class: String # "Vigilantes", "Heavies", "Mutants" [cite: 47, 52, 57]
@export var base_attack: float  # ATK [cite: 32]
@export var base_defense: float # DEF [cite: 33]
@export var base_health: float  # HP [cite: 34]
@export var base_power_value: int # How much Power 1 unit is worth [cite: 90]
@export var rock_paper_scissor_bonus: float = 1.25 # RPS Multiplier for being strong against a class
@export var rock_paper_scissor_penalty: float = 0.75 # RPS Multiplier for being weak against a class
