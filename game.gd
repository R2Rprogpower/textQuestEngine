extends Control

# Top bar
@onready var game_name_label: Label       = $MarginContainer/VBoxContainer/TopBar/GameNameLabel
@onready var chapter_label: Label         = $MarginContainer/VBoxContainer/TopBar/ChapterLabel
@onready var book_label: Label            = $MarginContainer/VBoxContainer/TopBar/BookLabel
@onready var location_label: Label        = $MarginContainer/VBoxContainer/TopBar/LocationLabel
@onready var time_label: Label            = $MarginContainer/VBoxContainer/TopBar/TimeLabel
@onready var date_label: Label            = $MarginContainer/VBoxContainer/TopBar/DateLabel
@onready var click_counter_label: Label   = $MarginContainer/VBoxContainer/TopBar/ClickCounterLabel

# Story + thoughts
@onready var story_text: RichTextLabel    = $MarginContainer/VBoxContainer/Middle/LeftPanel/StoryScroll/StoryText
@onready var thoughts_text: RichTextLabel = $MarginContainer/VBoxContainer/Middle/LeftPanel/ThoughtsText

# Right panel – player & surroundings
@onready var player_name_label: Label     = $MarginContainer/VBoxContainer/Middle/RightPanel/PlayerPanel/PlayerNameLabel
@onready var hp_label: Label              = $MarginContainer/VBoxContainer/Middle/RightPanel/PlayerPanel/HpLabel
@onready var mana_label: Label            = $MarginContainer/VBoxContainer/Middle/RightPanel/PlayerPanel/ManaLabel

@onready var objective_text: RichTextLabel    = $MarginContainer/VBoxContainer/Middle/RightPanel/ObjectiveText
@onready var surroundings_text: RichTextLabel = $MarginContainer/VBoxContainer/Middle/RightPanel/SurroundingsText

# Bottom – actions + static buttons
@onready var actions_container: VBoxContainer = $MarginContainer/VBoxContainer/BottomBar/ActionsPanel/ActionsContainer

@onready var inventory_button: Button    = $MarginContainer/VBoxContainer/BottomBar/StaticPanel/InventoryButton
@onready var equipment_button: Button    = $MarginContainer/VBoxContainer/BottomBar/StaticPanel/EquipmentButton
@onready var stats_button: Button        = $MarginContainer/VBoxContainer/BottomBar/StaticPanel/StatsButton
@onready var journal_button: Button      = $MarginContainer/VBoxContainer/BottomBar/StaticPanel/JournalButton

var click_count: int = 0


func _ready() -> void:
	# Temporary dummy data – just to see layout working
	game_name_label.text = "Demo Room"
	chapter_label.text = "Chapter 1"
	book_label.text = "Book I"
	location_label.text = "Unknown Room"
	time_label.text = "00:05"
	date_label.text = "Day 1"

	_update_click_counter()

	player_name_label.text = "Player"
	hp_label.text = "HP: 10 / 10"
	mana_label.text = "Mana: 5 / 5"

	story_text.text = "You wake up in a dim room. The air is heavy and smells like old code.\nThere is a door, a table, and the quiet awareness that this is only a prototype."
	thoughts_text.text = "I should probably not die in the tutorial."

	objective_text.text = "Objective: Explore the room and understand the UI."
	surroundings_text.text = "- Door (locked)\n- Table with note\n- Flickering light"

	_build_dynamic_actions([
		"Say something",
		"Shout",
		"Call for help",
		"Hit the door",
		"Take the note",
		"Inspect surroundings"
	])

	# Hook static buttons – real logic later
	inventory_button.pressed.connect(_on_inventory_pressed)
	equipment_button.pressed.connect(_on_equipment_pressed)
	stats_button.pressed.connect(_on_stats_pressed)
	journal_button.pressed.connect(_on_journal_pressed)


func _build_dynamic_actions(action_labels: Array[String]) -> void:
	# Clear old
	for child in actions_container.get_children():
		child.queue_free()

	for label in action_labels:
		var btn := Button.new()
		btn.text = label
		btn.custom_minimum_size = Vector2(0, 36)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_action_pressed.bind(label))
		actions_container.add_child(btn)


func _on_action_pressed(label: String) -> void:
	click_count += 1
	_update_click_counter()

	if Engine.has_singleton("AudioManager"):
		AudioManager.play_click()

	# For now just append to thoughts so you see something happen.
	thoughts_text.text += "\nYou chose: %s" % label

	# Later: map label -> GameState.choose_option(...) or interaction


func _update_click_counter() -> void:
	click_counter_label.text = "Clicks: %d" % click_count


func _on_inventory_pressed() -> void:
	if Engine.has_singleton("AudioManager"):
		AudioManager.play_click()
	# TODO: open inventory UI / popup


func _on_equipment_pressed() -> void:
	if Engine.has_singleton("AudioManager"):
		AudioManager.play_click()
	# TODO: open equipment UI


func _on_stats_pressed() -> void:
	if Engine.has_singleton("AudioManager"):
		AudioManager.play_click()
	# TODO: open stats UI


func _on_journal_pressed() -> void:
	if Engine.has_singleton("AudioManager"):
		AudioManager.play_click()
	# TODO: open journal / log
