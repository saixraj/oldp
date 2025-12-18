extends Node2D

signal return_to_map_requested

@onready var build_menu = $BuildMenu
@onready var train_menu = $TrainMenu

# Define your base slots logically (Grid Coordinates)
var building_slots = {
	Vector2i(2, 2): { "type": "Barracks", "level": 1, "occupied": true },
	Vector2i(4, 4): { "type": "Empty", "level": 0, "occupied": false }
}

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = get_local_mouse_position()
		var grid_pos = pixel_to_grid(local_pos) # You need to implement this math helper
		
		if grid_pos in building_slots:
			_handle_slot_click(grid_pos)

func _handle_slot_click(grid_pos):
	var slot = building_slots[grid_pos]
	
	if slot.occupied:
		print("Clicked existing building: ", slot.type)
		if slot.type == "Barracks":
			train_menu.open()
	else:
		print("Clicked empty slot. Opening Build Menu.")
		build_menu.open()
		# You'll need to store which slot is being built on
		build_menu.target_slot = grid_pos

func _on_building_constructed(type):
	# Tell Server we want to build
	# NetworkManager.send_action("build", type)
	pass
