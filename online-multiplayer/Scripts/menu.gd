extends Node3D
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect

@onready var button_2: Button = $CanvasLayer/Button2
@onready var button: Button = $CanvasLayer/Button


func _on_button_2_pressed() -> void:
	get_tree().quit()


func _on_button_pressed() -> void:
	button_2.hide()
	button.hide()
	color_rect.show()
