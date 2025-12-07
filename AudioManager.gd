extends Node

var click_player: AudioStreamPlayer

func _ready():
	click_player = AudioStreamPlayer.new()
	add_child(click_player)
	click_player.stream = preload("res://click.wav") # <- your file
	click_player.bus = "SFX" # or whatever bus you use for SFX

func play_click():
	click_player.stop()
	click_player.play()
