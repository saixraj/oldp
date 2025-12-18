extends CanvasLayer

signal return_requested

@onready var btn_return: Button = $Control/BtnReturn
@onready var stats_label: Label = $Control/VBoxContainer/StatsLabel


func _ready():
	# Update stats whenever the scene is shown
	update_stats()
	
	# Listen for global army updates
	Global.connect("army_updated", _on_global_army_updated)
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		print("DEBUG VIEWER: Screen opened. Refreshing stats...")
		update_stats()

func update_stats():
	# Clear previous text
	var text = ""
	
	# Loop through the army dictionary
	for unit_name in Global.army:
		var count = Global.army[unit_name]
		text += unit_name + ": " + str(count) + "\n"
		
	stats_label.text = text

func _on_global_army_updated(army_dict):
	print("DEBUG VIEWER: Received army update -> ", army_dict)
	update_stats()

func _on_btn_return_pressed():
	emit_signal("return_requested")
