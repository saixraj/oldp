# log_viewer.gd
extends PanelContainer # MUST match the root node type in LogViewer.tscn

signal closed

# @onready variables must match the new robust path
# Path: PanelContainer -> VBoxRoot -> Scroll -> LogRichText
@onready var log_text_label: RichTextLabel = $VBoxRoot/Scroll/LogRichText 
@onready var btn_close: Button = $VBoxRoot/BtnClose

# --- INITIALIZATION AND SIZING ---

func _ready():
	# 1. Set Size and Position (Fixes the Vector2 operator error and centers the window)
	size = Vector2(800, 600) 
	var screen_center = get_viewport().size / 2
	var window_offset = size / 2
	
	position = Vector2(
		int(screen_center.x - window_offset.x), 
		int(screen_center.y - window_offset.y)
	)
	
	visible = false
	
	# 2. Connection Safety Check (Fixes the 'null instance' crash)
	if is_instance_valid(btn_close):
		btn_close.pressed.connect(_on_btn_close_pressed)
	else:
		# This should only print if the node name/path is wrong
		print("ERROR: BtnClose not found in LogViewer.gd") 

# --- PUBLIC FUNCTIONS ---

# Public function to receive and display the log
func show_log(log_string):
	# Final check: Ensure the LogRichText node exists before trying to assign text
	print("--- VIEWER DEBUG: Received String Length: ", log_string.length())
	if is_instance_valid(log_text_label): 
		log_text_label.text = log_string
	else:
		# This is the last point of failure; indicates a scene tree mismatch
		print("CRITICAL ERROR: LogRichText node is missing or path is wrong!")
	
	# This displays the entire popup window
	visible = true

# --- SIGNAL HANDLERS ---

func _on_btn_close_pressed():
	visible = false
	emit_signal("closed")
