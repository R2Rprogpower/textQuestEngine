extends Button


func _on_pressed():
	var optionsBlock = $"../../Options"
	var mainButtons = $".."
	optionsBlock.show()
	mainButtons.hide()
