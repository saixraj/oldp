extends Area2D

signal base_clicked(node)

var player_name = "Unknown"
var base_level = 1
var defense_rating = 0 # Replaces 'power'
var lootable_scrap = 0
var lootable_dna = 0

var is_destroyed = false

func _ready():
	input_pickable = true
	$RecoveryTimer.timeout.connect(_on_recovery_timer_timeout)
	
func _process(delta):
	if is_destroyed:
		$TimerLabel.text = "Shield: " + str(int($RecoveryTimer.time_left)) + "s"
	else:
		$TimerLabel.text = ""

func setup_rival(p_name, p_level):
	player_name = p_name
	base_level = p_level
	_refresh_stats()

func _refresh_stats():
	# Estimated Strength: 4 Soldiers per level * (Atk+HP/4)
	defense_rating = base_level * 50 
	lootable_scrap = base_level * 500
	lootable_dna = base_level * 20
	
	$NameLabel.text = player_name
	$LevelLabel.text = "Lv " + str(base_level)
	$Sprite2D.modulate = Color(1, 0.5, 0.5) 
	is_destroyed = false

func defeat():
	is_destroyed = true
	$Sprite2D.modulate = Color(0.2, 0.2, 0.2) 
	$NameLabel.text = player_name + " (Defeated)"
	$RecoveryTimer.start()

func _on_recovery_timer_timeout():
	_refresh_stats()
	$NameLabel.text = player_name 

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_destroyed:
			get_viewport().set_input_as_handled()
			emit_signal("base_clicked", self)
