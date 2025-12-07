extends Button

func _on_pressed():
	var gameSelect = $".."              # parent Control with your sliders
	var mainButtons = $"../../MainButtons"
	gameSelect.hide()
	mainButtons.show()
	
