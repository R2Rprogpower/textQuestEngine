extends Control

const SETTINGS_PATH := "user://settings.cfg"


@onready var master_slider = $MasterVolumeSlider  
@onready var music_slider  = $MusicVolumeSlider 
@onready var sfx_slider    = $SfxVolumeSlider
@onready var fullscreen_check := $FullScreenCheckButton


func _ready():
	_load_settings()


	var mode = DisplayServer.window_get_mode()
	fullscreen_check.button_pressed = (mode == DisplayServer.WINDOW_MODE_FULLSCREEN)
	print("[Fullscreen] Ready. State detected: ",  )

	var master_bus := AudioServer.get_bus_index("Master")
	var music_bus  := AudioServer.get_bus_index("Music")
	var sfx_bus    := AudioServer.get_bus_index("SFX")
	
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))
	music_slider.value  = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sfx_slider.value    = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))		
		


func _on_master_volume_slider_value_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("Master")
	var db = linear_to_db(value)
	print(value)
	AudioServer.set_bus_volume_db(bus, db)

func _on_music_volume_slider_value_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("Music")
	var db = linear_to_db(value)
	print(value)
	AudioServer.set_bus_volume_db(bus, db)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("SFX")
	var db = linear_to_db(value)
	print(value)
	AudioServer.set_bus_volume_db(bus, db)


func _on_full_screen_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)



func _load_settings() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SETTINGS_PATH)
	if err == OK:
		var master: float = cfg.get_value("audio", "master", 1.0)
		var music: float  = cfg.get_value("audio", "music", 1.0)
		var sfx: float    = cfg.get_value("audio", "sfx", 1.0)	

		master_slider.value = master
		music_slider.value  = music
		sfx_slider.value    = sfx

		# apply to buses
		_on_master_volume_slider_value_changed(master)
		_on_music_volume_slider_value_changed(music)
		_on_sfx_volume_slider_value_changed(sfx)
		
				# ------- FULLSCREEN -------
		var fullscreen_enabled: bool = cfg.get_value("display", "fullscreen", false)
		$FullScreenCheckButton.button_pressed = fullscreen_enabled
		
		if fullscreen_enabled:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			
	else:
		# first run → defaults
		master_slider.value = 1.0
		music_slider.value  = 1.0
		sfx_slider.value    = 1.0
		_apply_all_sliders()
		
		$FullScreenCheckButton.button_pressed = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _apply_all_sliders() -> void:
	_on_master_volume_slider_value_changed(master_slider.value)
	_on_music_volume_slider_value_changed(music_slider.value)
	_on_sfx_volume_slider_value_changed(sfx_slider.value)


func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", master_slider.value)
	cfg.set_value("audio", "music",  music_slider.value)
	cfg.set_value("audio", "sfx",    sfx_slider.value)
	
	 # ------- FULLSCREEN -------
	cfg.set_value("display", "fullscreen", $FullScreenCheckButton.button_pressed)
	
	
	cfg.save(SETTINGS_PATH)
