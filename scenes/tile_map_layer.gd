extends TileMapLayer

# --- SIGNALS ---
signal request_menu(building_node)
signal tile_clicked(grid_pos) # Optional: signal if other scripts need to know
signal request_attack_menu(target_node)
signal request_hero_encounter(encounter_node)

# --- VARIABLES ---
# Load your building scene
var mcc_scene = preload("res://scenes/Building_MCC.tscn")
var rival_scene = preload("res://scenes/RivalBase.tscn")

# Variable for the ghost cursor
var hover_marker: Polygon2D 

# --- INITIALIZATION ---
func _ready():
	# 1. Create the Visual Cursor
	_setup_hover_marker()
	
	# 2. Spawn the Starting Base automatically
	# This puts a Level 1 MCC at grid (5, 5) immediately
	place_building_2x2(Vector2i(8,1))
	# Find all enemies and connect them
	for child in get_children():
		if child.has_signal("enemy_clicked"):
			child.enemy_clicked.connect(_on_enemy_selected)
	spawn_mmo_rivals(2) # Spawn 5 random players
	for node in get_children():
		if node.has_method("defeat") and "enemy_faction" in node: # Check for HeroEncounter properties
			node.hero_encounter_clicked.connect(_on_hero_encounter_clicked)

func _on_hero_encounter_clicked(encounter_node):
	print("Map: Requesting Hero Menu for ", encounter_node.encounter_name)
	emit_signal("request_hero_encounter", encounter_node)

func _on_enemy_selected(enemy_node):
	print("Map: Player wants to attack ", enemy_node.name)
	emit_signal("request_attack_menu", enemy_node)
	
	
# --- LOOP (Runs every frame) ---
func _process(_delta):
	# Update the position of the ghost marker to follow mouse
	var mouse_pos = get_global_mouse_position()
	var grid_coords = local_to_map(mouse_pos)
	
	if hover_marker:
		var world_pos = map_to_local(grid_coords)
		hover_marker.position = world_pos

# --- INPUT HANDLING ---
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var clicked_cell = local_to_map(mouse_pos)
		
		# Check if we clicked on valid ground (not empty space)
		if get_cell_source_id(clicked_cell) != -1:
			print("User clicked on Tile: ", clicked_cell)
			emit_signal("tile_clicked", clicked_cell)

# --- LOGIC FUNCTIONS ---
func place_building_2x2(top_left_cell: Vector2i):
	# Calculate the center point between the 4 tiles
	var p1 = map_to_local(top_left_cell)
	var p2 = map_to_local(top_left_cell + Vector2i(1, 1))
	var final_pos = (p1 + p2) / 2.0
	
	if mcc_scene:
		var new_building = mcc_scene.instantiate()
		new_building.position = final_pos
		add_child(new_building)
		
		# CRITICAL: Connect the building's click signal to this map
		new_building.connect("building_selected", _on_building_selected)
		print("Base pre-installed at: ", top_left_cell)

func _on_building_selected(building_node):
	print("Map received signal! Requesting Menu for: ", building_node.name)
	emit_signal("request_menu", building_node)

func _setup_hover_marker():
	# Remove old marker if it exists
	if hover_marker:
		hover_marker.queue_free()
	
	# Create a Polygon2D for the diamond shape
	var poly = Polygon2D.new()
	poly.color = Color(1, 1, 1, 0.3) # Semi-transparent white
	
	# Draw the diamond shape based on your tile size
	var ts = tile_set.tile_size 
	var points = PackedVector2Array([
		Vector2(0, -ts.y / 2.0), # Top
		Vector2(ts.x / 2.0, 0),  # Right
		Vector2(0, ts.y / 2.0),  # Bottom
		Vector2(-ts.x / 2.0, 0)  # Left
	])
	
	poly.polygon = points
	hover_marker = poly
	add_child(hover_marker)





####################DELETE LATER#################

func spawn_mmo_rivals(count):
	for i in range(count):
		# 1. Generate Fake Data
		var data = ServerMock.get_random_rival_data()
		
		# 2. Instantiate Base
		var rival = rival_scene.instantiate()
		rival.setup_rival(data["name"], data["level"])
		
		# 3. Random Position (Grid based)
		# Spread them out more than enemies
		var rand_x = randi_range(200, 1000) 
		var rand_y = randi_range(200, 600)
		rival.position = Vector2(rand_x, rand_y)
		
		# 4. Connect Signals
		if rival.has_signal("base_clicked"):
			rival.base_clicked.connect(_on_rival_selected)
			
		add_child(rival)

# --- NEW SIGNAL HANDLER ---
func _on_rival_selected(rival_node):
	print("Map: Requesting PvP Menu for ", rival_node.player_name)
	# We reuse the ATTACK MENU signal, but pass the Rival Node!
	emit_signal("request_attack_menu", rival_node)
