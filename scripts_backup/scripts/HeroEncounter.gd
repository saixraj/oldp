extends Area2D

# Signal to tell the Main Scene that this node was clicked and needs to open the Hero menu
signal hero_encounter_clicked(encounter_node)

@export var encounter_name = "Invaded Tower" 
@export var enemy_faction = "Revenants" # The faction of the monsters/tower (e.g., Arcanum, Revenants, etc.)
@export var level = 1
@export var xp_reward = 50 # Reward for defeating this encounter

func _ready():
	input_pickable = true
	# Placeholder visuals: later replace with actual sprite/scene
	$Sprite2D.modulate = Color(0.2, 0.2, 0.8) # Blue tint for exploration
	$Label.text = encounter_name + " Lvl " + str(level)
	
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Hero Encounter Clicked: ", encounter_name)
		get_viewport().set_input_as_handled()
		emit_signal("hero_encounter_clicked", self)

# Function called when the encounter is successfully defeated
func defeat():
	# For now, just remove it from the map
	queue_free()
