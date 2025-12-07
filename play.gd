extends Button


func _on_pressed():
	var gameSelect = $"../../GameSelect"
	var mainButtons = $".."
	gameSelect.show()
	mainButtons.hide()
