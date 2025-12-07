extends Control

signal game_selected(game_id: String)

const GAMES_ROOT := "res://games"  # root folder where all game folders live

@onready var game_list: VBoxContainer = $ScrollContainer/VBoxContainer   


func _ready() -> void:
	refresh_games()


func refresh_games() -> void:
	# Clear old buttons
	for child in game_list.get_children():
		child.queue_free()

	var dir := DirAccess.open(GAMES_ROOT)
	if dir == null:
		push_error("GameSelectBlock: cannot open games root: %s" % GAMES_ROOT)
		_add_info_label("No games folder found:\n" + GAMES_ROOT)
		return

	dir.list_dir_begin()
	var name := dir.get_next()
	var found_any := false

	while name != "":
		if dir.current_is_dir() and not name.begins_with("."):
			var game_id := name
			var json_path := "%s/%s/%s.json" % [GAMES_ROOT, game_id, game_id]
			if FileAccess.file_exists(json_path):
				var ok := _add_game_from_json(game_id, json_path)
				if ok:
					found_any = true
			else:
				push_warning("GameSelectBlock: JSON not found for game folder '%s' at '%s'" % [game_id, json_path])
		name = dir.get_next()

	dir.list_dir_end()

	if not found_any:
		_add_info_label("No valid games found in:\n" + GAMES_ROOT)


func _add_game_from_json(game_id: String, json_path: String) -> bool:
	var text := FileAccess.get_file_as_string(json_path)
	if text == "":
		push_warning("GameSelectBlock: empty JSON file: %s" % json_path)
		return false

	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		push_error("GameSelectBlock: JSON parse error in %s: %s" % [json_path, json.get_error_message()])
		return false

	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		push_error("GameSelectBlock: root of %s must be a Dictionary" % json_path)
		return false

	var title: String = String(data.get("title", game_id))
	var desc: String = String(data.get("description", ""))

	var btn := Button.new()
	btn.text = title if desc == "" else "%s\n[ %s ]" % [title, desc]

	# Make the text wrap
	var label := btn.get_child(0)
	if label is Label:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	btn.custom_minimum_size = Vector2(260, 48)  # or any width/height you like
	btn.pressed.connect(_on_game_button_pressed.bind(game_id))
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	 # --- ROW TO CENTER BUTTON HORIZONTALLY ---
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var left_spacer := Control.new()
	left_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var right_spacer := Control.new()
	right_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	row.add_child(left_spacer)
	row.add_child(btn)
	row.add_child(right_spacer)
	
	game_list.add_child(row)

	return true

func _add_info_label(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap = true
	game_list.add_child(label)


func _on_game_button_pressed(game_id: String) -> void:
	if Engine.has_singleton("AudioManager"):
		AudioManager.play_click()

	emit_signal("game_selected", game_id)
