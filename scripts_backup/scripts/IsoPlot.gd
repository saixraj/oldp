extends Area2D

# Signal to tell the Main Scene "I was clicked!"
signal plot_clicked(node_ref)

# Variables we will need later
var is_occupied = false
var building_type = "" 

func _ready():
	# Allow this node to catch mouse events
	input_pickable = true

# This built-in function detects clicks on the CollisionPolygon2D
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("DEBUG: Clicked on plot: ", name)
		
		# Prevent the click from passing through to the floor behind it
		get_viewport().set_input_as_handled()
		
		# Tell the system we were clicked
		emit_signal("plot_clicked", self)

# Optional: Add Hover Effect
func _mouse_enter():
	# Light up when mouse hovers
	$Polygon2D.color = Color(0.6, 0.6, 0.6) 

func _mouse_exit():
	# Return to dark gray when mouse leaves
	$Polygon2D.color = Color(0,0,0,0)


func mouse_enter() -> void:
	pass # Replace with function body.


func mouse_exit() -> void:
	pass # Replace with function body.
