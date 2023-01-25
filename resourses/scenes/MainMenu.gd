extends ReferenceRect

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")


func _on_QuitButton_button_down():
	get_tree().quit()


func _on_SettingsButton_button_down():
	$SettingsContainer.popup()


func _on_PlayButton_button_down():
	get_tree().change_scene("res://resourses/scenes/GameMaster.tscn")


func _on_HostButton_button_down():
	var peer := NetworkedMultiplayerENet.new()
	print("Hosting server")
	print(peer.create_server(3030, 2))
	get_tree().network_peer = peer
	print("Host ip: " + String(IP.get_local_addresses()))
	get_tree().change_scene("res://resourses/scenes/multiplayer/MultiTest.tscn")


func _on_JoinButton_button_down():
	var peer := NetworkedMultiplayerENet.new()
	print("Connecting to local IP")
	print(peer.create_client("127.0.0.1", 3030))
	get_tree().network_peer = peer
	get_tree().change_scene("res://resourses/scenes/multiplayer/MultiTest.tscn")


func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	print("Player connected: " + String(id))
