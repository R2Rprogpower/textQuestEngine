extends Control
func _ready():
	_wire_click_sounds(self)
	
func _wire_click_sounds(node: Node):
	if node is Button:
		node.pressed.connect(_on_any_button_pressed)
	for child in node.get_children():
		_wire_click_sounds(child)


func _on_any_button_pressed():
	AudioManager.play_click()
