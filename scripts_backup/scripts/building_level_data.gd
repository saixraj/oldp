extends Resource
class_name BuildingLevelData

# Metadata
@export_group("Level Info")
@export var level_index: int = 1
@export var build_time_seconds: float = 0.0

# Visuals
@export_group("Visuals")
# In Godot, Prefabs are "PackedScenes" (.tscn files)
@export var visual_scene: PackedScene 

# Costs
@export_group("Resource Costs")
@export_subgroup("Tier 1 (Raw)")
@export var scrap_cost: int = 0
@export var wood_cost: int = 0

@export_subgroup("Tier 2 (Refined)")
@export var steel_cost: int = 0
@export var planks_cost: int = 0

@export_subgroup("Tier 3 (Rare)")
@export var aether_cost: int = 0
