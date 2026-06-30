extends Node3D
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var player: Node2D = $CanvasLayer/player
@onready var title: Node2D = $CanvasLayer/Title
@onready var progress_bar: ProgressBar = $CanvasLayer/player/ProgressBar
@onready var line_edit: LineEdit = $CanvasLayer/ColorRect/Scale/LineEdit
@onready var button_2: Button = $CanvasLayer/Button2
@onready var button: Button = $CanvasLayer/Button
const PLAYER = preload("uid://dak7erwf73sy5")
const port = 9999
var enet_peer = ENetMultiplayerPeer.new()
func _on_button_2_pressed() -> void:
	get_tree().quit()


func _on_button_pressed() -> void:
	button_2.hide()
	button.hide()
	title.hide()
	color_rect.show()


func _on_host_pressed() -> void:
	color_rect.hide()
	enet_peer.create_server(port)
	multiplayer.multiplayer_peer = enet_peer
	spawn(multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(spawn)
	player.show()
	multiplayer.peer_disconnected.connect(remove)
	upnp()

func _on_join_pressed() -> void:
	color_rect.hide()
	enet_peer.create_client(line_edit.text,port)
	multiplayer.multiplayer_peer = enet_peer
	player.show()


func _on_back_pressed() -> void:
	button_2.show()
	button.show()
	title.show()
	color_rect.hide()
func spawn(peer_id):
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player)
	if player.is_multiplayer_authority():
		player.damaged.connect(update_bar)
func update_bar(healthval):
	progress_bar.value = healthval


func _on_multiplayer_spawner_spawned(node: Node) -> void:
	if node.is_multiplayer_authority():
		node.damaged.connect(update_bar)

func remove(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
		
func upnp():
	var upnp = UPNP.new()
	var result = upnp.discover()
	var map = upnp.add_port_mapping(port)
	assert(result == UPNP.UPNP_RESULT_SUCCESS, "Discover Failed, Error %s" %result)
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), "Invalid Gateway")
	assert(map == UPNP.UPNP_RESULT_SUCCESS, "Port Mapping Failed, Error %s" %map)
	print("Success! Join Port:%" %upnp.query_external_address())
