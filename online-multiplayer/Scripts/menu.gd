extends Node3D
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var title: Node2D = $CanvasLayer/Title
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

func _on_join_pressed() -> void:
	color_rect.hide()
	enet_peer.create_client("localhost",port)
	multiplayer.multiplayer_peer = enet_peer


func _on_back_pressed() -> void:
	button_2.show()
	button.show()
	title.show()
	color_rect.hide()
func spawn(peer_id):
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player)
