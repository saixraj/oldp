extends Node

# You will need a WebSocketPeer or a library like Godot-Go-Proto
var socket = WebSocketPeer.new()
var server_url = "ws://127.0.0.1:8080/ws"

func _ready():
	connect_to_server()

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var data = socket.get_packet()
			_handle_packet(data)
	elif state == WebSocketPeer.STATE_CLOSED:
		print("Disconnected from server")

func connect_to_server():
	socket.connect_to_url(server_url)
	print("Connecting to MMO Server...")

func send_action(type, target, payload_str=""):
	# In reality, you serialize Protobuf here
	# For this example, we mock the serialization
	var packet_data = { "type": type, "target": target, "payload": payload_str }
	socket.put_packet(JSON.stringify(packet_data).to_utf8_buffer())

func _handle_packet(data):
	# Deserialize Protobuf here. 
	# For simplicity, assuming JSON for the transition logic explanation:
	var msg = JSON.parse_string(data.get_string_from_utf8())
	
	if "resources" in msg:
		# Pass data to GameState (formerly Global)
		Global.update_from_server(msg.resources, msg.army)
	
	if "battle_log" in msg:
		# Pass battle result to CombatManager to visualize
		CombatManager.play_battle_replay(msg.battle_log)
