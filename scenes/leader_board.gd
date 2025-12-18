extends CanvasLayer

@onready var list_label = $Control/Panel/VBoxContainer/ListLabel
@onready var root_control: PanelContainer = $LogViewer

func _ready():
	# Ensure the control node is positioned correctly (if it's not a CanvasLayer child)
	# This section may not be needed if your Panel is anchored correctly, but is a safe addition.
	if is_instance_valid(root_control):
		root_control.size = Vector2(900, 700) # Give it a large size
		var screen_center = get_viewport().size / 2
		var window_offset = root_control.size / 2
		
		root_control.position = Vector2(
			int(screen_center.x - window_offset.x), 
			int(screen_center.y - window_offset.y)
		)
	
	visible = false

func open():
	print("DEBUG: Opening Leaderboard...")
	if list_label == null:
		print("ERROR: ListLabel node not found!")
		return

	visible = true
	refresh_board()

# leader_board.gd (REPLACE the entire refresh_board function)

func refresh_board():
	# 1. Get Data from the Global GuildManager Singleton
	# NOTE: We are using GuildManager instead of a non-existent ServerMock
	var data = GuildManager.get_leaderboard_data()
	
	# Check if data was retrieved successfully
	if data.is_empty():
		list_label.text = "[center]ERROR: No Guild Data Retrieved.[/center]"
		return
		
	print("DEBUG: Received ", data.size(), " entries from GuildManager.")
	
	# 2. Build Text
	var text = "[center][b][color=yellow]TOP GUILDS (POWER RATING)[/color][/b][/center]\n\n"
	var rank = 1
	
	for entry in data:
		# Use the combined tag and name, and display power_rating as the score
		var line = str(rank) + ". " + entry["tag"] + " " + entry["name"] + " - [b]" + str(entry["power_rating"]) + " Power[/b]"
		text += line + "\n"
		rank += 1
		
	text += "[/center]"
	
	# 3. Apply to Label
	list_label.text = text
	
	# 4. CRITICAL DEBUG: Print what should be on screen
	print("--- LEADERBOARD TEXT ---")
	print(text)
	print("------------------------")

func _on_btn_close_pressed():
	visible = false
