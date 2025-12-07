extends Button

func _on_pressed():
	var optionsBlock = $".."              # parent Control with your sliders
	optionsBlock._save_settings() 	
	var mainButtons = $"../../MainButtons"
	optionsBlock.hide()
	mainButtons.show()
	
