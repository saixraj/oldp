extends CanvasLayer

@onready var btn_barracks: Button = $Control/Panel/VBoxContainer/BtnBarracks
@onready var btn_smelter: Button = $Control/Panel/VBoxContainer/BtnSmelter
@onready var btn_cancel: Button = $Control/Panel/VBoxContainer/BtnCancel


# Signal to tell the InnerBase what we chose
signal building_chosen(type)
signal menu_closed

func _ready():
	# Hide menu by default
	visible = false

# --- BUTTON SIGNALS ---
# Connect these in the editor!

func _on_btn_barracks_pressed():
	emit_signal("building_chosen", "Barracks")
	close_menu()

func _on_btn_smelter_pressed():
	emit_signal("building_chosen", "Smelter")
	close_menu()

func _on_btn_cancel_pressed():
	close_menu()

# --- HELPER FUNCTIONS ---
func open():
	visible = true
	check_requirements()

func check_requirements():
	# 1. Check Barracks (Requires Level 3)
	var bar_req = GameData.building_stats["Barracks"]["req_level"]
	if Global.mcc_level >= bar_req:
		btn_barracks.disabled = false
		btn_barracks.text = "Barracks (100 Wood)"
	else:
		btn_barracks.disabled = true
		btn_barracks.text = "Barracks (Locked - Req Lvl " + str(bar_req) + ")"

	# 2. Check Smelter (Requires Level 5)
	var smelt_req = GameData.building_stats["Smelter"]["req_level"]
	if Global.mcc_level >= smelt_req:
		btn_smelter.disabled = false
		btn_smelter.text = "Smelter (100 Scrap)"
	else:
		btn_smelter.disabled = true
		btn_smelter.text = "Smelter (Locked - Req Lvl " + str(smelt_req) + ")"

func close_menu():
	visible = false
	emit_signal("menu_closed")
