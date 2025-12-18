# WorldMap.gd
extends Node2D

# --- PRESERVED CONFIGURATION (Must be updated to your final art size) ---
var tile_width = 128   
var tile_height = 64
const MAP_GRID_SIZE = 120 # Estimate a large grid size for your 4096x4096 map (e.g., 4096 / 32 = 128)
const MAP_WIDTH = 2816
const MAP_HEIGHT = 1536

# --- PRELOADED SCENES (Required for Spawning) ---
var mcc_scene = preload("res://scenes/Building_MCC.tscn")
var rival_scene = preload("res://scenes/RivalBase.tscn")
var hero_encounter_scene = preload("res://scenes/HeroEncounter.tscn") # Assume this exists

# --- NODE REFERENCES & STATE ---
@onready var map_texture: Sprite2D = $MapTexture
@onready var camera: Camera2D = $Camera2D
var hover_marker: Polygon2D # The visual cursor

var is_dragging = false
var drag_start_pos = Vector2.ZERO
var camera_start_pos = Vector2.ZERO

# --- PRESERVED SIGNALS ---
signal request_menu(building_node)
signal tile_clicked(grid_pos)
signal request_attack_menu(target_node)
signal request_hero_encounter(encounter_node)


# --- INITIALIZATION ---
func _ready():
	# 1. Setup Camera and Bounds
	_setup_camera()
	
	# 2. Setup Visual Cursor (The diamond marker)
	_setup_hover_marker()

	# 3. Spawn initial game entities
	# Note: This is now based on our mathematical grid, not TileMap's grid
	place_building_2x2(Vector2i(8,1))
	spawn_mmo_rivals(5) 
	for child in get_children():
		if child.has_signal("enemy_clicked"):
			child.enemy_clicked.connect(_on_enemy_selected)
		if child.has_signal("hero_encounter_clicked"):
			child.hero_encounter_clicked.connect(_on_hero_encounter_clicked)
	
	# Future: Logic to connect existing child nodes (not needed on startup, but kept for clarity)
	# for child in get_children():
	# 	if child.has_signal("enemy_clicked"):
	# 		child.enemy_clicked.connect(_on_enemy_selected)


# --- CAMERA & MOVEMENT SETUP ---

# WorldMap.gd

func _setup_camera():
	# REMOVE THIS LINE: map_texture.texture.set_size_override(Vector2(MAP_WIDTH, MAP_HEIGHT))
	
	# 1. FIX: Set the texture's visible region to the full size
	map_texture.region_enabled = true
	map_texture.region_rect = Rect2(0, 0, MAP_WIDTH, MAP_HEIGHT)
	
	# Optional: Disable texture filtering for a cleaner pixel look
	map_texture.texture_filter = TEXTURE_FILTER_NEAREST
	
	# 2. Set Camera Bounds (This part remains correct)
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = MAP_WIDTH
	camera.limit_bottom = MAP_HEIGHT
	
	# 3. Center the Camera
	camera.position = Vector2(MAP_WIDTH / 2, MAP_HEIGHT / 2)


# --- HOVER MARKER (RE-WRITTEN) ---
func _setup_hover_marker():
	if hover_marker:
		hover_marker.queue_free()
	
	# Create a Polygon2D for the diamond shape
	var poly = Polygon2D.new()
	poly.color = Color(1, 1, 1, 0.3) 
	
	# Draw the diamond shape based on our constants
	var half_ts_x = tile_width / 2.0
	var half_ts_y = tile_height / 2.0
	var points = PackedVector2Array([
		Vector2(0, -half_ts_y), # Top
		Vector2(half_ts_x, 0),  # Right
		Vector2(0, half_ts_y),  # Bottom
		Vector2(-half_ts_x, 0)  # Left
	])
	
	poly.polygon = points
	hover_marker = poly
	add_child(hover_marker) # Add the marker to the WorldMap scene

# --- LOOP (Runs every frame) ---
func _process(_delta):
	var mouse_pos = camera.get_global_mouse_position()
	var grid_coords = pixel_to_iso(mouse_pos)
	
	if hover_marker:
		# Use the new iso_to_pixel function for placement
		var world_pos = iso_to_pixel(grid_coords)
		hover_marker.position = world_pos

# --- INPUT HANDLING (Click, Drag, and Interaction) ---
func _unhandled_input(event):
	# DRAGGING LOGIC
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_pos = event.position
				camera_start_pos = camera.position
			else:
				is_dragging = false
	
	if event is InputEventMouseMotion and is_dragging:
		var drag_delta = event.position - drag_start_pos
		camera.position = camera_start_pos - drag_delta

	# INTERACTION LOGIC (Right-Click for now, since Left is for dragging)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		var mouse_pos = camera.get_global_mouse_position()
		var clicked_cell = pixel_to_iso(mouse_pos)
		
		# Now, we would check the GameData array (world_cells) instead of TileMap:
		# if GameData.world_cells[clicked_cell.x][clicked_cell.y].type != "empty":
		
		print("User clicked on Grid: ", clicked_cell)
		emit_signal("tile_clicked", clicked_cell)

# --- LOGIC FUNCTIONS (Preserved and Adjusted) ---

# The TileMap functions are replaced with our math core:
# Converts World Pixels -> Isometric Grid Coordinates (For Logic)
func pixel_to_iso(pixel_coords: Vector2) -> Vector2:
	var half_width = tile_width * 0.5
	var half_height = tile_height * 0.5
	
	var iso_x = (pixel_coords.x / half_width + pixel_coords.y / half_height) * 0.5
	var iso_y = (pixel_coords.y / half_height - (pixel_coords.x / half_width)) * 0.5
	
	return Vector2(floor(iso_x), floor(iso_y))

# Converts Isometric Grid Coordinates -> World Pixels (For Placement)
func iso_to_pixel(grid_coords: Vector2) -> Vector2:
	var half_width = tile_width * 0.5
	var half_height = tile_height * 0.5
	
	var x = (grid_coords.x - grid_coords.y) * half_width
	var y = (grid_coords.x + grid_coords.y) * half_height
	
	return Vector2(x, y)


func place_building_2x2(top_left_cell: Vector2i):
	# Calculate the center point for the 2x2 structure
	var p1 = iso_to_pixel(top_left_cell)
	var p2 = iso_to_pixel(top_left_cell + Vector2i(1, 1))
	var final_pos = (p1 + p2) / 2.0
	
	if mcc_scene:
		var new_building = mcc_scene.instantiate()
		new_building.position = final_pos
		add_child(new_building)
		
		new_building.connect("building_selected", _on_building_selected)
		print("Base pre-installed at: ", top_left_cell)

# --- PRESERVED SIGNAL HANDLERS ---
func _on_building_selected(building_node):
	print("Map received signal! Requesting Menu for: ", building_node.name)
	emit_signal("request_menu", building_node)

func _on_enemy_selected(enemy_node):
	print("Map: Player wants to attack ", enemy_node.name)
	emit_signal("request_attack_menu", enemy_node)
	
func _on_hero_encounter_clicked(encounter_node):
	print("Map: Requesting Hero Menu for ", encounter_node.encounter_name)
	emit_signal("request_hero_encounter", encounter_node)

func _on_rival_selected(rival_node):
	print("Map: Requesting PvP Menu for ", rival_node.player_name)
	emit_signal("request_attack_menu", rival_node)


# --- ENEMY SPAWNING (Adjusted for World Coordinates) ---
func spawn_mmo_rivals(count):
	# Get the dictionary of rival guilds we defined in GuildManager
	var guilds = GuildManager.rival_guilds
	var guild_ids = guilds.keys()
	
	for i in range(count):
		# Pick a random guild from our MMO data
		var random_id = guild_ids[randi() % guild_ids.size()]
		var guild_data = guilds[random_id]
		
		var rival = rival_scene.instantiate()
		
		# We pass the Guild Tag and Name to the Rival Base UI
		var display_name = guild_data["tag"] + " " + guild_data["name"]
		rival.setup_rival(display_name, randi_range(5, 15))
		
		# Store the guild ID on the node so the combat system knows who we hit
		rival.set_meta("guild_id", random_id)
		
		var rand_x = randi_range(500, MAP_WIDTH - 500) 
		var rand_y = randi_range(500, MAP_HEIGHT - 500)
		rival.position = Vector2(rand_x, rand_y)
		
		if rival.has_signal("base_clicked"):
			rival.base_clicked.connect(_on_rival_selected)
			
		add_child(rival)
